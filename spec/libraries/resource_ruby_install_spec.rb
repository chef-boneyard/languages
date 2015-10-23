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

describe Chef::Resource::RubyInstall do
  subject { Chef::Resource::RubyInstall.new(version, run_context) }
  let(:node) { stub_node(platform: 'ubuntu', version: '12.04') }
  let(:run_context) { Chef::RunContext.new(node, {}, nil) }
  let(:version) { '2.1.7' }

  it 'has a default prefix of /opt/rubies' do
    expect(subject.prefix).to eq('/opt/rubies')
  end

  it 'properly sets the version' do
    expect(subject.version).to eq('2.1.7')
  end

  context 'when the prefix is set to something non-default' do
    let(:prefix) { '/usr/local' }

    before do
      subject.prefix prefix
    end

    it 'obeys sets the prefix to the requested path' do
      expect(subject.prefix).to eq('/usr/local')
    end
  end
end
