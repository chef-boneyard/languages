#
# Cookbook Name:: languages
# HWRP:: ruby_install
#
# Copyright 2014, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
require_relative '_helper'
require 'yaml'

class Chef
  class Resource::RubyInstall < Resource::LWRPBase
    resource_name :ruby_install

    actions :install
    default_action :install

    attribute :version,     kind_of: String, name_attribute: true
    attribute :environment, kind_of: Hash, default: {}
    attribute :patches,     kind_of: Array, default: []
    attribute :prefix,      kind_of: String, default: Chef::Platform.windows? ? ::File.join(ENV['SYSTEMDRIVE'], 'rubies') : '/opt/rubies'
    # This attribute is only meaningful on windows. It is passed
    # through to the DevKitInstall resource.
    attribute :devkit_path, kind_of: String, default: nil

    def patch(patch)
      @patches << patch
    end
  end

  # TODO: Fix installed?
  class Provider::RubyInstallUnix < Provider::LWRPBase
    provides :ruby_install

    def whyrun_supported?
      true
    end

    action(:install) do
      if installed?
        Chef::Log.debug("#{new_resource} installed - skipping")
      else
        converge_by("install #{new_resource}") do
          install
        end
      end
    end

    def self.compile_flags
      [
        '--disable-install-rdoc',
        '--disable-install-ri',
        '--with-out-ext=tcl',
        '--with-out-ext=tk',
        '--without-tcl',
        '--without-tk',
        '--disable-dtrace',
      ].join(' ')
    end

    protected

    def version
      new_resource.version
    end

    def install
      install_dependencies

      # Need to compile the command outside of the execute resource because
      # Ruby is bad at instance_eval
      install_command = "ruby-install --no-install-deps --install-dir #{ruby_path}"

      new_resource.patches.each do |p|
        install_command << " --patch #{p}"
      end

      install_command << " ruby #{version} -- #{Provider::RubyInstallUnix.compile_flags}"

      execute = Resource::Execute.new("install ruby-#{version}", run_context)
      execute.command(install_command)
      execute.environment(new_resource.environment)
      execute.run_action(:run)

      install_bundler
    end

    # Check if the given Ruby is installed in the given prefix.
    #
    # @return [true, false]
    def installed?
      ::File.executable?("#{ruby_path}/bin/ruby")
    end

    def ruby_path
      "#{new_resource.prefix}/ruby-#{new_resource.version}"
    end

    def install_bundler
      execute = Resource::Execute.new('install bundler', run_context)
      execute.command("#{ruby_path}/bin/gem install bundler")
      execute.environment(new_resource.environment)
      execute.run_action(:run)
    end

    def install_dependencies
      recipe_eval do
        run_context.include_recipe 'build-essential::default'
      end

      # TODO: extract to a _common recipe for the common deps per language install
      if debian?
        install_package('libxml2-dev')
        install_package('libxslt-dev')
        install_package('zlib1g-dev')
        install_package('ncurses-dev')
        install_package('libssl-dev')
      elsif freebsd?
        install_package('textproc/libxml2')
        install_package('textproc/libxslt')
        install_package('devel/ncurses')
        install_package('libssl-dev')
      elsif mac_os_x?
        install_package('libxml2')
        install_package('libxslt')
        install_package('libssl-dev')
      elsif rhel?
        install_package('libxml2-devel')
        install_package('libxslt-devel')
        install_package('ncurses-devel')
        install_package('zlib-devel')
        install_package('libssl-devel')
      end

      # install ruby-install
      return if Chef::Sugar::Shell.installed_at_version?('/usr/local/bin/ruby-install', '0.4.1')
      ruby_install = Chef::Resource::RemoteInstall.new('ruby-install', run_context)
      ruby_install.source('https://codeload.github.com/postmodern/ruby-install/tar.gz/v0.4.1')
      ruby_install.version('0.4.1')
      ruby_install.checksum('1b35d2b6dbc1e75f03fff4e8521cab72a51ad67e32afd135ddc4532f443b730e')
      ruby_install.install_command("make -j #{parallelism} install")
      ruby_install.run_action(:install)
    end

    def install_package(package_str)
      pkg = Chef::Resource::Package.new(package_str, run_context)
      pkg.run_action(:install)
    end

    # The number of builders to use for make. By default, this is the total
    # number of CPUs, with a minimum being 2.
    def parallelism
      [node['cpu'] && node['cpu']['total'].to_i, 2].max
    end
  end

  class Provider::RubyInstallWindows < Provider::LWRPBase
    include Languages::Helper

    provides :ruby_install, platform_family: 'windows'

    def whyrun_supported?
      true
    end

    action(:install) do
      install_ruby
      install_devkit
      configure_ca
      update_rubygems
      install_bundler
    end

    protected

    def version
      new_resource.version
    end

    def installer_url
      "http://dl.bintray.com/oneclick/rubyinstaller/rubyinstaller-#{version}.exe"
    end

    def installer_download_path
      windows_safe_path_join(Chef::Config[:file_cache_path], ::File.basename(installer_url))
    end

    # Determines the proper version of the DevKit based on Ruby version.
    def devkit_version
      # 2.0 64-bit
      if version =~ /^2\.\d\.\d.*x64$/
        'mingw64-64-4.7.2-20130224-1432'
      # 2.0 32-bit
      elsif version =~ /^2\.\d\.\d.*$/
        'mingw64-32-4.7.2-20130224-1151'
      # Ruby 1.8.7 and 1.9.3
      else
        'tdm-32-4.5.2-20111229-1559'
      end
    end

    def ruby_install_path
      windows_safe_path_join(new_resource.prefix, "ruby-#{new_resource.version}")
    end

    def ruby_bin
      windows_safe_path_join(ruby_install_path, 'bin', 'ruby.exe')
    end

    def bundler_bin
      windows_safe_path_join(ruby_install_path, 'bin', 'bundler.bat')
    end

    def ssl_certs_dir
      windows_safe_path_join(ruby_install_path, 'ssl', 'certs')
    end

    def cacert_file
      windows_safe_path_join(ssl_certs_dir, 'cacert.pem')
    end

    # Installs the desired version of the RubyInstaller
    def install_ruby
      if ::File.executable?(ruby_bin)
        Chef::Log.debug("#{new_resource} ruby installed - skipping")
        return
      end
      converge_by("install #{new_resource} ruby") do
        ruby_installer = Resource::RemoteFile.new("fetch ruby-#{version}", run_context)
        ruby_installer.path(installer_download_path)
        ruby_installer.source(installer_url)
        ruby_installer.backup(false)
        ruby_installer.run_action(:create)

        install_command = %(#{installer_download_path} /verysilent /dir="#{ruby_install_path}" /tasks="assocfiles")

        execute = Resource::Execute.new("install ruby-#{version}", run_context)
        execute.command(install_command)
        execute.run_action(:run)
      end
    end

    # Installs the DevKit in the Ruby so we can compile gems with native extensions.
    def install_devkit
      devkit = Resource::DevkitInstall.new(devkit_version, run_context)
      devkit.prefix(new_resource.devkit_path) if new_resource.devkit_path
      devkit.run_action(:install)

      config_yaml = windows_safe_path_join(ruby_install_path, 'config.yml')
      yaml_entry = ruby_install_path.gsub(::File::ALT_SEPARATOR, ::File::SEPARATOR)
      if ::File.exist?(config_yaml) && ::YAML.load_file(config_yaml).include?(yaml_entry)
        Chef::Log.debug("#{new_resource} ruby already associated with devkit - skipping")
        return
      end

      converge_by("register #{new_resource} ruby with devkit") do
        # Reload the yaml file in case it was modified by a previous resource.
        if ::File.exist?(config_yaml)
          append_block = Resource::RubyBlock.new('merge with existing devkit registrations', run_context)
          append_block.block do
            config = ::YAML.load_file(config_yaml)
            Chef::Log.debug("{new_resource} existing devkit has config.yml: #{config}")
            config << yaml_entry
            ::File.open(config_yaml, 'w') { |f| f.write config.to_yaml }
          end
          append_block.run_action(:run)
        else
          config_yaml_resource = Resource::File.new(config_yaml, run_context)
          config_yaml_resource.content([yaml_entry].to_yaml)
          config_yaml_resource.run_action(:create)
        end
      end
    end

    # Ensures a certificate authority is available and configured. See:
    #
    #   https://gist.github.com/fnichol/867550
    #
    def configure_ca
      if ::File.exist?(cacert_file)
        Chef::Log.debug("#{new_resource} ca certs installed - skipping")
        return
      end
      converge_by("initialize #{new_resource} SSL CA certificate file") do
        certs_dir = Resource::Directory.new(ssl_certs_dir, run_context)
        certs_dir.recursive(true)
        certs_dir.run_action(:create)

        cacerts = Resource::CookbookFile.new("install cacerts bundle for ruby-#{version}", run_context)
        cacerts.path(cacert_file)
        cacerts.source('cacert.pem')
        cacerts.cookbook('languages')
        cacerts.backup(false)
        cacerts.sensitive(true)
        cacerts.run_action(:create)
      end
    end

    # We need the latest version of rubygems.  Older versions ship
    # with a bad certificate file that doesn't allow you to access rubygems.
    def update_rubygems
      converge_by("update rubygems for #{new_resource}") do
        execute = Resource::RubyExecute.new('gem update --system', run_context)
        execute.version(version)
        execute.prefix(new_resource.prefix)
        execute.environment('SSL_CERT_FILE' => cacert_file)
        execute.gem_home('')
        execute.run_action(:run)
      end
    end

    def install_bundler
      if ::File.executable?(bundler_bin)
        Chef::Log.debug("#{new_resource} bundler installed - skipping")
        return
      end
      converge_by("install bundler for #{new_resource}") do
        execute = Resource::RubyExecute.new('gem install bundler', run_context)
        execute.version(version)
        execute.prefix(new_resource.prefix)
        execute.gem_home('')
        execute.run_action(:run)
      end
    end
  end
end
