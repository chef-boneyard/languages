#
# Cookbook Name:: languages
# HWRP:: erlang_execute
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
  class Resource::ErlangExecute < Resource::LanguageExecute
    resource_name :erlang_execute
  end

  class Provider::ErlangExecute < Provider::LWRPBase
    include Languages::Helper

    provides :erlang_execute

    action(:run) do
      raise "No erlang found under #{new_resource.prefix}. Please run erlang_install first." unless installed?
      execute
    end

    protected

    def environment
      environment = new_resource.environment || {}
      # ensure we don't destroy the `PATH` value set by the user
      existing_path = environment.delete('PATH')
      environment['PATH'] = [erlang_path, existing_path].compact.join(::File::PATH_SEPARATOR)
      environment
    end

    def erlang_path
      "#{new_resource.prefix}/erlang/#{new_resource.version}/bin"
    end

    def installed?
      ::File.directory?(erlang_path)
    end

    def execute
      erlang_resource = Resource::Execute.new("Running erlang command '#{new_resource.command}'", run_context)
      erlang_resource.command(new_resource.command)
      erlang_resource.environment(environment)
      erlang_resource.sensitive(new_resource.sensitive)
      erlang_resource.cwd(new_resource.cwd)
      erlang_resource.user(new_resource.user)
      erlang_resource.run_action(:run)
    end
  end
end
