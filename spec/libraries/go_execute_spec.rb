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

require 'chef'
require 'spec_helper'

RSpec.shared_context :go_data do
  let(:language) { 'go' }
  let(:version) { '1.5.2' }
  let(:command) { 'go version' }
end

describe Chef::Resource::GoExecute do
  include_context :resource_boilerplate
  include_context :go_data
  it_behaves_like :language_resource

  subject { Chef::Resource::GoExecute.new(command, run_context) }
end

describe Chef::Provider::GoExecute do
  include_context :resource_boilerplate
  include_context :go_data
  it_behaves_like :language_execute_provider

  let(:resource) do
    r = Chef::Resource::GoExecute.new(command, run_context)
    r.version(version)
    r
  end

  subject { Chef::Provider::GoExecute.new(resource, run_context) }
end
