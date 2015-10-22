#
# Cookbook Name:: omnibus
# HWRP:: ruby_install
#
# Copyright 2014, Chef Software, Inc.
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

class Chef
  class Resource::RubyExecute < Resource::LWRPBase
    self.resource_name = :ruby_execute

    actions :run
    default_action :run

    attribute :command, kind_of: String, name_attribute: true
    attribute :version, kind_of: String
    attribute :environment, kind_of: Hash, default: {}
    attribute :prefix, kind_of: String
  end

  class Provider::RubyExecuteUnix < Provider::LWRPBase
    provides :ruby_execute

    action(:run) do
      raise "No ruby found under #{new_resource.prefix}. Please run ruby_install first." unless installed?
      execute
    end

    def execute
      execute_resource = Resource::Execute.new("executing ruby at #{ruby_path} command", run_context)
      execute_resource.command("#{ruby_path}/bin/#{new_resource.command}")
      execute_resource.environment(new_resource.environment)
      execute_resource.run_action(:run)
    end

    def ruby_path
      "#{new_resource.prefix}/ruby-#{new_resource.version}"
    end


    def installed?
      ::File.directory?(ruby_path)
    end

  end
end
