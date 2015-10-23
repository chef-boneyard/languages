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

describe Chef::Provider::RubyExecute do
  subject { Chef::Provider::RubyExecute.new(resource, run_context) }

  let(:command) { 'gem install json' }

  let(:run_context) { Chef::RunContext.new(node, {}, nil) }
  let(:node) { stub_node(platform: 'ubuntu', version: '12.04') }
  let(:version) { '2.1.7' }
  let(:prefix) { '/usr/local' }
  let(:ruby_path) { "#{prefix}/ruby-#{version}" }
  let(:environment) do
    {
      'FOO' => 'BAR',
    }
  end
  let(:resource) do
    r = Chef::Resource::RubyExecute.new(command, run_context)
    r.environment(environment)
    r.prefix(prefix)
    r.version(version)
    r
  end

  before do
    allow_any_instance_of(Chef::Resource::Execute).to receive(:run_action)
  end

  context '#execute' do
    it 'calls Resource::Execute object command method with proper input' do
      expect_any_instance_of(Chef::Resource::Execute).to receive(:command).with("#{ruby_path}/bin/#{command}")
      subject.send(:execute)
    end

    it 'calls Resource::Execute.run_action(:run)' do
      expect_any_instance_of(Chef::Resource::Execute).to receive(:run_action).with(:run)
      subject.send(:execute)
    end

    context 'when the path is set' do
      let(:execute_resource) do
        double(
          Chef::Resource::Execute,
          command: nil,
          cwd: nil,
          environment: nil,
          run_action: nil,
          user: nil,
          group: nil,
        )
      end

      before do
        allow(Chef::Resource::Execute).to receive(:new).and_return(execute_resource)
      end

      it 'appends the ruby path to PATH' do
        expect(execute_resource).to receive(:environment).with(hash_including('PATH' => [ruby_path, ENV['PATH']].join(::File::PATH_SEPARATOR)))
        subject.send(:execute)
      end
    end
  end

  context '#installed?' do
    context 'when the prefix exists' do
      before do
        allow(File).to receive(:directory?).with("#{prefix}/ruby-#{version}").and_return(true)
      end

      it 'returns true' do
        expect(subject.send(:installed?)).to eq(true)
      end
    end

    context 'when the prefix does not exist' do
      before do
        allow(File).to receive(:directory?).with("#{prefix}/ruby-#{version}").and_return(false)
      end

      it 'returns false' do
        expect(subject.send(:installed?)).to eq(false)
      end
    end
  end
end
