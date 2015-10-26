#
# Cookbook Name:: languages
# HWRP:: node_execute
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
  class Resource::NodeExecute < ChefCompat::Resource
    resource_name :node_execute

    property :command, kind_of: String, name_property: true
    property :version, kind_of: String

    # Useful propertys from the `execute` resource that might need overriding
    property :cwd, kind_of: String
    property :environment, kind_of: Hash, default: {}
    property :user, kind_of: [String, Integer]
    property :sensitive, kind_of: [TrueClass, FalseClass], default: false

    prefix = '/opt/languages/node'

    load_current_value do
      current_value_does_not_exist! if node.run_state['nodejs'].nil?
      version node.run_state['nodejs'][:version]
    end

    action :run do
      execute 'execute-node' do
        cwd new_resource.cwd
        environment new_resource.environment
        user new_resource.user
        sensitive new_resource.sensitive
        # gsub replaces 10+ spaces at the beginning of the line with nothing
        command <<-CODE.gsub(/^ {10}/, '')
          #{prefix}/#{new_resource.version}/bin/#{new_resource.command}
        CODE
      end
    end
  end
end
