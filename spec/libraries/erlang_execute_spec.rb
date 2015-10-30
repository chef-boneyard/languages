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

RSpec.shared_context :erlang_data do
  let(:language) { 'erlang' }
  let(:version) { '18.1' }
  let(:command) { "erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell" }
end

describe Chef::Resource::ErlangExecute do
  include_context :resource_boilerplate
  include_context :erlang_data
  it_behaves_like :language_resource

  subject { Chef::Resource::ErlangExecute.new(command, run_context) }
end

describe Chef::Provider::ErlangExecute do
  include_context :resource_boilerplate
  include_context :erlang_data
  it_behaves_like :language_execute_provider

  let(:resource) do
    r = Chef::Resource::ErlangExecute.new(command, run_context)
    r.version(version)
    r
  end

  subject { Chef::Provider::ErlangExecute.new(resource, run_context) }
end
