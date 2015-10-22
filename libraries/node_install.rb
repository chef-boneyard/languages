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

class Chef
  class Resource::NodeInstall < ChefCompat::Resource
    resource_name :node_install

    property :node_version, kind_of: String, name_property: true
    property :prefix, kind_of: String, default: '/usr/local/bin'

    action :install do
      remote_file '/tmp/nvm_install.sh' do
        source 'https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh'
        mode '0755'
        not_if { ::File.exist?("#{prefix}/nvm") }
      end
      execute 'nvm-install' do
        command "PROFILE=/etc/profile NVM_DIR=#{prefix}/nvm /tmp/nvm_install.sh"
        not_if { ::File.exist?("#{prefix}/nvm") }
      end
      converge_if_changed :node_version do
        bash 'install-node' do
          # gsub replaces 10+ spaces at the beginning of the line with nothing
          code <<-CODE.gsub(/^ {10}/, '')
            . #{prefix}/nvm/nvm.sh
            nvm install #{node_version}
          CODE
        end
      end
    end
  end
end
