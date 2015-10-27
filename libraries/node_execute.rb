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
    property :returns, kind_of: [Integer, Array], default: 0

    load_current_value do
      current_value_does_not_exist! if node.run_state['nodejs'].nil?
      version node.run_state['nodejs'][:version]
    end

    action :run do
      execute 'execute-node' do
        cwd new_resource.cwd
        environment envr
        user new_resource.user
        sensitive new_resource.sensitive
        returns new_resource.returns
        command new_resource.command
      end
    end

    # This is called envr due to resource name collisions
    def envr
      environment ||= {}
      # ensure we don't destroy the `PATH` value set by the user
      environment['PATH'] = [node_path, ENV['PATH']].compact.join(::File::PATH_SEPARATOR)
      environment
    end

    def node_path
      prefix = '/opt/languages/node'
      ::File.join(prefix, "#{version}", 'bin')
    end
  end
end
