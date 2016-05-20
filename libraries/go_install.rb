#
# Cookbook Name:: opscode-ci
# HWRP:: go_install
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

class Chef
  class Resource::GoInstall < Resource::LanguageInstall
    resource_name :go_install
  end
end

class Chef
  class Provider::GoInstall < Provider::LanguageInstall
    provides :go_install,
             platform_family: %w(
               debian
               mac_os_x
               rhel
               windows
             )

    #
    # @see Chef::Resource::LanguageInstall#installed?
    #
    def installed?
      # installed_at_version?(::File.join(new_resource.prefix, 'bin', 'go'), new_resource.version, 'version')
      # go_version = Chef::Resource::GoExecute.new('go version')
      # go_version.version = new_resource.version
      # go_version.prefix = new_resource.prefix
      # go_version.action(:run)

      ::File.exist?(::File.join(new_resource.prefix, 'bin', 'go'))
    end

    #
    # @see Chef::Resource::LanguageInstall#install
    #
    def install
      download_go
      install_go
    end

    def install_dependencies
      super

      package 'tar' if debian? || rhel?
    end

    private

    def download_go
      go_directory = Resource::Directory.new(new_resource.prefix, run_context)
      go_directory.recursive(true)
      go_directory.run_action(:create)

      download_go = Chef::Resource::RemoteFile.new(::File.join(Chef::Config[:file_cache_path], tarball), run_context)
      download_go.source("https://storage.googleapis.com/golang/#{tarball}")
      download_go.run_action(:create)
    end

    def install_go
      install_go = Chef::Resource::Execute.new("tar -C #{new_resource.prefix} -xzvf #{tarball} --strip-components=1", run_context)
      install_go.cwd(Chef::Config[:file_cache_path])
      install_go.run_action(:run)
    end

    def tarball
      "go#{new_resource.version}.#{os}-#{arch}.tar.gz"
    end

    def os
      if linux?
        'linux'
      elsif windows?
        'windows'
      elsif mac_os_x?
        'darwin'
      end
    end

    def arch
      if _64_bit?
        'amd64'
      else
        '386'
      end
    end
  end
end
