#
# Cookbook Name:: languages
# HWRP:: node_install
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

require 'chef_compat/resource'
require 'mixlib/shellout'

class Chef
  class Resource::NodeInstall < ChefCompat::Resource
    resource_name :node_install

    property :version, kind_of: String, name_property: true
    prefix = '/opt/languages/node'

    action :install do
      node.run_state['nodejs'] = {
        version: new_resource.version,
      }
      remote_file "#{Config[:file_cache_path]}/nvm_install.sh" do
        source 'https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh'
        mode '0755'
        not_if { ::File.exist?('/usr/local/bin/nvm/nvm.sh') }
      end
      execute 'nvm-install' do
        command "NVM_DIR=/usr/local/bin/nvm #{Config[:file_cache_path]}/nvm_install.sh"
        not_if { ::File.exist?('/usr/local/bin/nvm/nvm.sh') }
      end
      directory prefix do
        recursive true
        not_if { ::File.exist?(prefix) }
      end
      execute 'install-node' do
        # gsub replaces 10+ spaces at the beginning of the line with nothing
        command <<-CODE.gsub(/^ {10}/, '')
          . /usr/local/bin/nvm/nvm.sh
          nvm install #{new_resource.version}
          NODE_PATH=$( dirname $(nvm which #{new_resource.version}))
          cp -R $NODE_PATH/../../#{new_resource.version} #{prefix}/
        CODE
        not_if { ::File.exist?("#{prefix}/#{new_resource.version}") }
      end
    end
  end
end
