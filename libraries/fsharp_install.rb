#
# Cookbook Name:: languages
# HWRP:: fsharp_install
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

require_relative 'language_install'
require_relative 'windows_helper'

class Chef
  class Resource::FsharpInstall < Resource::LanguageInstall
    resource_name :fsharp_install
  end

  class Provider::FsharpInstall < Provider::LanguageInstall
    provides :fsharp_install,
             platform_family: %w(
               debian
               rhel
             )

    MONO_VERSION = '4.2.1.124'.freeze
    MONO_CHECKSUM = '6098476ce5c74685b23e7a96be8fe28a27db4167375fee103a275820054d647c'.freeze

    FSHARP_VERSION = '4.0.1.1'.freeze
    FSHARP_CHECKSUM = '133b5c3ae2364417be15a3768158a6fbab4411e73fb6ffb607f8137a39df7557'.freeze

    #
    # @see Chef::Resource::LanguageInstall#installed?
    #
    def installed?
      ::File.exist?(::File.join(new_resource.prefix, 'bin', 'fsharpc'))
    end

    #
    # @see Chef::Resource::LanguageInstall#install_dependencies?
    # Installing Mono
    def install_dependencies
      super

      package 'tar' if debian? || rhel?

      return if ::File.exist?('/usr/local/bin/mono')

      mono_directory = Resource::Directory.new(new_resource.prefix, run_context)
      mono_directory.recursive(true)
      mono_directory.run_action(:create)

      mono_install = Resource::RemoteInstall.new('mono', run_context)
      mono_install.source("http://download.mono-project.com/sources/mono/mono-#{MONO_VERSION}.tar.bz2")
      mono_install.version('4.2.1')
      mono_install.checksum(MONO_CHECKSUM)
      mono_install.environment(mono_environment)
      mono_install.build_command('./configure')
      mono_install.compile_command('make')
      mono_install.install_command('make install')
      mono_install.run_action(:install)

      mono_sync = Resource::Execute.new('get NuGet Certs', run_context)
      mono_sync.command('mozroots --import --sync')
      mono_sync.run_action(:run)
    end

    #
    # @see Chef::Resource::LanguageInstall#install
    #
    def install
      # ensure the destination directory exists
      fsharp_directory = Resource::Directory.new(new_resource.prefix, run_context)
      fsharp_directory.recursive(true)
      fsharp_directory.run_action(:create)

      ENV['PKG_CONFIG_PATH'] = '/usr/local/lib/pkgconfig/'
      ENV['LD_LIBRARY_PATH'] = '$LD_LIBRARY_PATH:/usr/local/lib/'

      fsharp_install = Resource::RemoteInstall.new('fsharp', run_context)
      fsharp_install.source("https://codeload.github.com/fsharp/fsharp/tar.gz/#{new_resource.version}")
      fsharp_install.build_command("./autogen.sh --prefix #{new_resource.prefix}")
      fsharp_install.version("#{new_resource.version}")
      fsharp_install.environment(fsharp_environment)
      fsharp_install.checksum(FSHARP_CHECKSUM)
      fsharp_install.compile_command('make')
      fsharp_install.install_command('make install')
      fsharp_install.run_action(:install)
    end

    private

    def mono_environment
      {
        'VERSION' => '4.2.1',
      }
    end

    def mono_path
      ::File.join(Chef::Config[:file_cache_path], "mono-#{MONO_VERSION}")
    end

    def fsharp_environment
      {
        'LD_LIBRARY_PATH' => '$LD_LIBRARY_PATH:/usr/local/lib/',
        'PKG_CONFIG_PATH' => '/usr/local/lib/pkgconfig',
      }
    end

    def fsharp_path
      ::File.join(Chef::Config[:file_cache_path], "fsharp-#{new_resource.version}")
    end
  end

  class Provider::FsharpInstallWindows < Provider::FsharpInstall
    provides :fsharp_install, platform_family: 'windows'

    #
    # @see Chef::Resource::LanguageInstall#installed?
    #
    def installed?
      ::File.exist?(::File.join(new_resource.prefix, 'bin', 'fsc.exe'))
    end

    #
    # @see Chef::Resource::LanguageInstall#install_dependencies
    #
    def install_dependencies
      # windk_installer = Resource::WindowsPackage.new('Windows SDK Install', run_context)
      # windk_installer.source('http://download.microsoft.com/download/B/0/C/B0C80BA3-8AD6-4958-810B-6882485230B5/standalonesdk/sdksetup.exe')
      # windk_installer.options(installer_options)
      # windk_installer.installer_type(:custom)
      # windk_installer.run_action(:install)

      # build_tools_installer = Resource::WindowsPackage.new('Build Tools Install', run_context)
      # build_tools_installer.source('https://download.microsoft.com/download/E/E/D/EEDF18A8-4AED-4CE0-BEBE-70A83094FC5A/BuildTools_Full.exe')
      # build_tools_installer.options(installer_options)
      # build_tools_installer.installer_type(:custom)
      # build_tools_installer.run_action(:install)

      windk_get = Resource::RemoteFile.new('Fetch Windows SDK Installer', run_context)
      windk_get.path('/chef/windows_sdk.exe')
      windk_get.source('http://download.microsoft.com/download/B/0/C/B0C80BA3-8AD6-4958-810B-6882485230B5/standalonesdk/sdksetup.exe')
      windk_get.backup(false)
      windk_get.run_action(:create)

      windk_install = Resource::Execute.new('Install Windows SDK', run_context)
      windk_install.command('./chef/windows_sdk.exe /q')
      windk_install.not_if(::File.exist?('C:\\Program Files(x86)\\Microsoft SDKs\\Windows\\v8.1A\\bin\\NETFX 4.5.1 Tools\\gacutil'))
      windk_install.run_action(:run)

      build_tools_get = Resource::RemoteFile.new('Fetch Build Tools Installer', run_context)
      build_tools_get.path('/chef/BuildTools_Full.exe')
      build_tools_get.source('https://download.microsoft.com/download/E/E/D/EEDF18A8-4AED-4CE0-BEBE-70A83094FC5A/BuildTools_Full.exe')
      build_tools_get.backup(false)
      build_tools_get.run_action(:create)

      build_tools_install = Resource::Execute.new('Install Win Build Tools', run_context)
      build_tools_install.command('./chef/BuildTools_Full.exe /Full /Silent')
      build_tools_install.not_if(::File.exist?('C:\\Program Files(x86)\\MSBuild\\14.0\\Bin\\MSBuild'))
      build_tools_install.run_action(:run)
    end

    #
    # @see Chef::Resource::LanguageInstall#install
    #
    def install
      #  fsharp_installer = Resource::WindowsPackage.new('fsharp', run_context)
      #  fsharp_installer.source(fsharp_installer_url)
      #  fsharp_installer.options(installer_options)
      #  fsharp_installer.installer_type(:inno)
      #  fsharp_installer.run_action(:install)

      fsharp_get = Resource::RemoteFile.new('Fetch F# Installer', run_context)
      fsharp_get.source(fsharp_installer_url)
      fsharp_get.path('/chef/FSharp_Bundle.exe')
      fsharp_get.backup(false)
      fsharp_get.run_action(:create)

      fsharp_install = Resource::Execute.new('Install F#', run_context)
      fsharp_install.command('./chef/Fsharp_Bundle.exe /install /quiet')
      fsharp_install.not_if(::File.exist?('C:\\Program Files(x86)\\Microsoft SDKs\\F#\\4.0\\Framework\\v4.0\\Fsc.exe'))
      fsharp_install.run_action(:run)

      fsharp_pathing = Resource::Env.new('path', run_context)
      fsharp_pathing.delim(::File::PATH_SEPARATOR)
      fsharp_pathing.value("#{ENV['Path']};C:\\Program Files (x86)\\Microsoft SDKs\\F#\\4.0\\Framework\\v4.0")
      fsharp_pathing.run_action(:modify)
    end

    private

    def installer_options
      [
        '/install',
        '/quiet',
      ].join(' ')
    end

    def fsharp_installer_url
      'http://download.microsoft.com/download/9/1/2/9122D406-F1E3-4880-A66D-D6C65E8B1545/FSharp_Bundle.exe'
    end
  end
end
