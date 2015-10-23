#
# Cookbook Name:: languages
# HWRP:: erlang_install
#
# Copyright 2015, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef
  class Resource::ErlangInstall < Resource::LWRPBase
    resource_name :erlang_install

    actions :install
    default_action :install

    attribute :version,  kind_of: String, name_attribute: true
    attribute :prefix,   kind_of: String, default: '/usr/local'
  end
end

class Chef
  class Provider::ErlangInstall < Provider::LWRPBase
    require_relative '_helper'
    include Languages::Helper

    provides :erlang_install

    def whyrun_supported?
      true
    end

    action(:install) do
      Chef::Log.debug("CURRENT #{installed_erlang_version} DESIRED #{new_resource.version}")
      if installed_erlang_version
        Chef::Log.info("erlang is up-to-date with version #{new_resource.version} -- skipping")
      else
        converge_by("Create #{new_resource}") do
          install_dependencies
          install_kerl
          activate_kerl
          configure_kerl
          build_erlang
          install_erlang
        end
      end
    end

    protected

    def installed_erlang_version
      version_cmd = Mixlib::ShellOut.new("#{Config[:file_cache_path]}/kerl list installations")
      version_cmd.run_command
      version_cmd.stdout.include?("#{new_resource.version} #{new_resource.prefix}/erlang/#{new_resource.version}")
    rescue Errno::ENOENT
      false
    end

    def install_dependencies
      recipe_eval do
        run_context.include_recipe 'build-essential::default'
      end

      # from http://docs.basho.com/riak/latest/ops/building/installing/erlang/
      deps = %w(curl autoconf libncurses5-dev openssl libssl-dev fop xsltproc unixodbc-dev git) if debian?
      deps = %w(curl glibc-devel ncurses-devel openssl-devel autoconf java-1.8.0-openjdk-devel git) if rhel?

      deps.each do |dep|
        install_package(dep)
      end
    end

    def install_package(package_name)
      package = Chef::Resource::Package.new(package_name, run_context)
      package.package_name(package_name)
      package.run_action(:install)
    end

    def install_kerl
      kerlfile = Chef::Resource::RemoteFile.new('kerl', run_context)
      kerlfile.source('https://raw.githubusercontent.com/spawngrid/kerl/4e7c4349ddcd46ac11cd4cd50bfbda25f1f11ca2/kerl')
      kerlfile.path("#{Config[:file_cache_path]}/kerl")
      kerlfile.mode('0755')
      kerlfile.run_action(:create)
    end

    def activate_kerl
      activate_cmd = Chef::Resource::Execute.new('update_releases', run_context)
      activate_cmd.command("#{Config[:file_cache_path]}/kerl update releases")
      activate_cmd.run_action(:run)
    end

    def configure_kerl
      # kerl only supports setting KERL_BASE_DIR via a .kerlrc
      kerl_content = <<-EOH.gsub(/^ {8}/, '')
        KERL_DOWNLOAD_DIR=#{Config[:file_cache_path]}/#{new_resource.version}
        KERL_BUILD_DIR=#{Config[:file_cache_path]}/#{new_resource.version}
      EOH

      kerl_config = Chef::Resource::File.new('kerlrc', run_context)
      kerl_config.path("#{ENV['HOME']}/.kerlrc")
      kerl_config.content(kerl_content)
      kerl_config.run_action(:create)
    end

    def build_erlang
      kerl_cmd = Chef::Resource::Execute.new("build_kerl_#{new_resource.version}", run_context)
      kerl_cmd.command("#{Config[:file_cache_path]}/kerl build #{new_resource.version} #{new_resource.version}")
      kerl_cmd.run_action(:run)
    end

    def install_erlang
      install_cmd = Chef::Resource::Execute.new("install_kerl_#{new_resource.version}", run_context)
      install_cmd.command("#{Config[:file_cache_path]}/kerl install #{new_resource.version} #{new_resource.prefix}/erlang/#{new_resource.version}")
      install_cmd.run_action(:run)
    end
  end
end
