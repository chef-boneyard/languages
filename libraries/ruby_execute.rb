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

    # Specifies the GEM_HOME.
    # This prevents global gem state by always setting a
    # default not local to global ruby installation cache.
    # We default this to #{CWD}/gem_cache if not specified by user.
    # This will be where ruby looks for gems, and where bundle install will
    # install by default. So it will "just work" if the user bundle installs
    # and bundle.
    attribute :gem_home,
              kind_of: [String],
              default: lazy { |r| ::File.join((r.cwd || Dir.pwd), 'gem_cache')  }
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
        script_resource = if Chef::Platform::windows?
          Resource::PowershellScript.new("executing ruby at #{ruby_path} command", run_context)
        else
          Resource::BashScript.new("executing ruby at #{ruby_path} command", run_context)
        end
        script_resource.code <<-EOH
          ls env: | Out-File -Append -FilePath ~\\log.txt -Encoding ASCII
          echo '#{new_resource.command}' | Out-File -Append -FilePath ~\\log.txt -Encoding ASCII
          #{new_resource.command} 2>&1 | Out-File -Append -FilePath ~\\log.txt -Encoding ASCII
        EOH
        script_resource.environment(environment)
        puts ("\n\nENVIRONMENT: #{script_resource.environment}\nCOMMAND: #{new_resource.command}")
        # Pass through some default attributes for the `execute` resource
        script_resource.cwd(new_resource.cwd) unless new_resource.cwd == ''
        script_resource.user(new_resource.user) unless new_resource.user == ''
        script_resource.sensitive(new_resource.sensitive)
        script_resource.run_action(:run)
      end
    end

    def environment
      environment = new_resource.environment.dup || {}
      # ensure we don't destroy the `PATH` value set by the user
      existing_path = environment.delete('PATH') || ENV['PATH']
      path_var_name = Chef::Platform::windows? ? 'Path' : 'PATH'
      environment[path_var_name] = [ruby_path, existing_path].compact.join(::File::PATH_SEPARATOR)

      if new_resource.gem_home && new_resource.gem_home != ''
        environment['GEM_HOME'] = ::File.expand_path(new_resource.gem_home)
      end

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
