#
# Cookbook Name:: languages
# HWRP:: go_execute
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

require_relative 'language_execute'

class Chef
  class Resource::GoExecute < Resource::LanguageExecute
    resource_name :go_execute

    attribute :go_path,
              kind_of: String,
              default: '/opt/languages/go/gopath'
  end

  class Provider::GoExecute < Provider::LanguageExecute
    provides :go_execute

    #
    # @see Chef::Resource::LanguageExecute#environment
    #
    def environment
      create_gopath # ensure gopath exists

      environment = super
      environment['GOROOT'] = new_resource.prefix
      environment['GOPATH'] = new_resource.go_path
      environment
    end

    private

    def create_gopath
      gopath = Resource::Directory.new(new_resource.go_path, run_context)
      gopath.recursive(true)
      gopath.run_action(:create)
    end
  end
end
