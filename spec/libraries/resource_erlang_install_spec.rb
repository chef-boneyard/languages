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

describe Chef::Resource::ErlangInstall do
  subject { Chef::Resource::ErlangInstall.new(version, run_context) }
  let(:node) { stub_node(platform: 'ubuntu', version: '12.04') }
  let(:run_context) { Chef::RunContext.new(node, {}, nil) }
  let(:version) { '18.1' }

  it 'has a default prefix of /usr/local' do
    expect(subject.prefix).to eq('/usr/local')
  end
end
