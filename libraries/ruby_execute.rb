#
# Cookbook Name:: omnibus
# HWRP:: ruby_execute
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

require_relative '_helper'
require_relative 'language_execute'

class Chef
  class Resource::RubyExecute < Resource::LanguageExecute
    resource_name :ruby_execute
  end

  class Provider::RubyExecute < Provider::LWRPBase
    include Languages::Helper

    provides :ruby_execute

    action(:run) do
      raise "No ruby found under #{new_resource.prefix}. Please run ruby_install first." unless installed?
      execute
    end

    protected

    def execute
      with_clean_env do
        execute_resource = Resource::Execute.new("executing ruby at #{ruby_path} command", run_context)
        execute_resource.command(new_resource.command)
        execute_resource.environment(environment)

        # Pass through some default attributes for the `execute` resource
        execute_resource.cwd(new_resource.cwd)
        execute_resource.user(new_resource.user)
        execute_resource.sensitive(new_resource.sensitive)
        execute_resource.run_action(:run)
      end
    end

    def environment
      environment = new_resource.environment || {}
      # ensure we don't destroy the `PATH` value set by the user
      existing_path = environment.delete('PATH')
      environment['PATH'] = [ruby_path, existing_path].compact.join(::File::PATH_SEPARATOR)
      environment
    end

    def ruby_path
      if windows?
        windows_safe_path_join(new_resource.prefix, "ruby-#{new_resource.version}", 'bin')
      else
        ::File.join(new_resource.prefix, "ruby-#{new_resource.version}", 'bin')
      end
    end

    def installed?
      ::File.directory?(ruby_path)
    end
  end
end
