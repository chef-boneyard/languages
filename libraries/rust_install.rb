#
# Cookbook Name:: opscode-ci
# HWRP:: rust_install
#
# Copyright 2014, Chef Software, Inc.
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
  class Resource::RustInstall < Resource::LWRPBase
    resource_name :rust_install

    actions :install, :uninstall
    default_action :install

    attribute :version, kind_of: String, name_attribute: true
    attribute :channel, kind_of: String
    attribute :prefix, kind_of: String, default: '/usr/local'
  end
end

class Chef
  class Provider::RustInstall < Provider::LWRPBase
    require_relative '_helper'
    include Languages::Helper

    def whyrun_supported?
      true
    end

    action(:install) do
      Chef::Log.info("CURRENT:  #{current_rust_version}, NEW:  #{new_resource.version}")
      if current_rust_version == new_resource.version
        Chef::Log.info("#{new_resource} is up-to-date - skipping")
      else
        converge_by("Create #{new_resource}") do
          if windows?
            install_rust_windows
          else
            fetch_rust_installer
            run_rust_installer
          end
        end
      end
    end

    private

    #
    # Current version of rust installed
    #
    # @return String
    #
    def current_rust_version
      # Make sure this works on windows.
      # Subtract 1 from the date in order to get the correct version number; the existing recipe has been quietly installing the same thing over and over again.
      `#{new_resource.prefix}/rustc --version`.split.last[0..-2]
    rescue Errno::ENOENT
      'NONE'
    end

    def install_rust_windows
      package = Resource::WindowsPackage.new('rust')
      # Assumes we will always use the 64-bit environment for rust.
      package.source("https://static.rust-lang.org/dist/#{new_resource.version}/rust-#{new_resource.channel}-x86_64-pc-windows-gnu.msi")
      package.run_action(:install)
    end

    def fetch_rust_installer
      rust_installer = Resource::RemoteFile.new('rust_installer', run_context)
      rust_installer.source('https://static.rust-lang.org/rustup.sh')
      rust_installer.path("#{Config[:file_cache_path]}/rustup.sh")
      rust_installer.run_action(:create)
    end

    def run_rust_installer
      rustup_cmd = ['bash',
                    "#{Config[:file_cache_path]}/rustup.sh",
                    "--channel=#{new_resource.channel}",
                    "--prefix=#{new_resource.prefix}",
                    "--date=#{new_resource.version}",
                    '--yes'].join(' ')

      # Assumes OS X is a dev machine.
      rustup_cmd << ' --disable-sudo' if mac_os_x?

      execute = Resource::Execute.new("install_rust_#{new_resource.version}", run_context)
      execute.command(rustup_cmd)
      execute.run_action(:run)
    end
  end
end
