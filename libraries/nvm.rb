#
# Cookbook Name:: languages
# HWRP:: nvm_install
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
  class Resource::Nvm < ChefCompat::Resource
    resource_name :nvm

    property :name, kind_of: String, name_property: true
    property :node_version, kind_of: String
    # property :prefix, kind_of: String, default: '/usr/local/bin'
    property :command, kind_of: String

    def initialize(name, run_context = nil)
      super
      return if ::File.exist?('/usr/local/bin/nvm')
      nvm = Chef::Resource::RemoteFile.new('/tmp/nvm_install.sh', run_context)
      nvm.source('https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh')
      nvm.mode('0755')
      nvm.run_action(:create)
      nvm_install = Chef::Resource::Execute.new('nvm-install', run_context)
      nvm_install.command('NVM_DIR=/usr/local/bin/nvm /tmp/nvm_install.sh')
      nvm_install.run_action(:run)
    end

    action :install do
      bash 'install-node' do
        code <<-CODE.gsub(/^ {10}/, '')
          . /usr/local/bin/nvm/nvm.sh
          nvm install #{node_version}
        CODE
      end
    end

    action :run do
      bash 'nvm-run' do
        code <<-CODE.gsub(/^ {10}/, '')
          . #{prefix}/nvm/nvm.sh
          nvm run #{command}
        CODE
      end
    end

    action :execute do
      bash 'nvm-execute' do
        code <<-CODE.gsub(/^ {10}/, '')
          . #{prefix}/nvm/nvm.sh
          nvm exec #{command}
        CODE
      end
    end
  end
end
