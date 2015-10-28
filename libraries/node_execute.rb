#
# Cookbook Name:: languages
# HWRP:: node_execute
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

class Chef
  class Resource::NodeExecute < Resource::LanguageExecute
    resource_name :node_execute
  end

  class Provider::NodeExecute < Provider::LWRPBase
    include Chef::Mixin::ShellOut

    provides :node_execute

    def whyrun_supported?
      true
    end

    action(:run) do
      execute_resource = Resource::Execute.new(new_resource.command, run_context)
      execute_resource.environment(environment)

      # Pass through some default attributes for the `execute` resource
      execute_resource.cwd(new_resource.cwd)
      execute_resource.user(new_resource.user)
      execute_resource.returns(new_resource.returns)
      execute_resource.sensitive(new_resource.sensitive)
      execute_resource.run_action(:run)
    end

    protected

    def environment
      environment = new_resource.environment || {}
      # ensure we don't destroy the `PATH` value set by the user
      existing_path = environment.delete('PATH')
      environment['PATH'] = [node_path, existing_path, ENV['PATH']].compact.join(::File::PATH_SEPARATOR)
      # `npm` gets cranky when $HOME is not set
      # environment['HOME'] = Chef::Config[:file_cache_path] #unless environment.key?('HOME')
      environment
    end

    def node_path
      ::File.join(new_resource.prefix, 'bin')
    end
  end
end
