#
# Cookbook Name:: languages
# HWRP:: ruby_install
#
# Copyright 2015, Chef Software, Inc.
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
require 'chef_compat/resource'

require_relative '_helper'

class Chef
  class Resource::DevkitInstall < ChefCompat::Resource
    resource_name :devkit_install

    provides :devkit_install, platform_family: 'windows'

    property :version, kind_of: String, name_property: true
    property :prefix, kind_of: String, default: ::File.join(ENV['SYSTEMDRIVE'], 'devkit')

    def url
      if version == 'tdm-32-4.5.2-20111229-1559'
        'https://github.com/downloads/oneclick/rubyinstaller/DevKit-tdm-32-4.5.2-20111229-1559-sfx.exe'
      else
        "http://cdn.rubyinstaller.org/archives/devkits/DevKit-#{version}-sfx.exe"
      end
    end

    def download_path
      windows_safe_path_join(Chef::Config[:file_cache_path], ::File.basename(url))
    end

    def install_path
      windows_safe_path_join(prefix, "Devkit-#{version}")
    end

    action :install do
      if ::File.exist?(windows_safe_path_join(install_path, 'dk.rb'))
        Chef::Log.debug("#{new_resource} installed - skipping")
        return
      end

      remote_file download_path do
        source url
        not_if { ::File.exist?(download_path) }
      end

      execute 'deploy DevKit to destination' do
        command %(#{download_path} -y -o"#{install_path}")
      end
    end

  end
end
