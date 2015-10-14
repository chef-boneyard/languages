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

describe Chef::Resource::RustInstall do
  subject { Chef::Resource::RustInstall.new(version, run_context) }
  let(:node) { stub_node(platform: 'ubuntu', version: '14.04') }
  let(:run_context) { Chef::RunContext.new(node, {}, nil) }
  let(:version) { '1.3.0' }

  it 'has a default channel' do
    expect(subject.channel).to eq('stable')
  end

  it 'has a default prefix' do
    expect(subject.prefix).to eq('/usr/local')
  end

  # Not sure these tests are all that interesting
  context 'nightly channel' do
    let(:version) { '2015-10-03' }

    it 'has version set to 2015-10-03' do
      expect(subject.version).to eq('2015-10-03')
    end

    it 'has channel set to nightly' do
      subject.channel('nightly')
      expect(subject.channel).to eq('nightly')
    end
  end

  # windows:  HOLD OFF UNTIL I TALK TO MATT.
end
