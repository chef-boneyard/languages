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

describe Chef::Resource::NodeInstall do
  subject { Chef::Resource::NodeInstall.new(node_version, run_context) }
  let(:node) { stub_node(platform: 'ubuntu', version: '12.04') }
  let(:run_context) { Chef::RunContext.new(node, {}, nil) }
  let(:node_version) { '4.1.2' }

  it 'has a default prefix of /usr/local/bin' do
    expect(subject.prefix).to eq('/usr/local/bin')
  end

  it 'properly sets the version' do
    expect(subject.node_version).to eq('4.1.2')
  end

  context 'when the prefix is set to something non-default' do
    let(:prefix) { '/opt/foo' }

    before do
      subject.prefix prefix
    end

    it 'obeys sets the prefix to the requested path' do
      expect(subject.prefix).to eq('/opt/foo')
    end
  end
end
