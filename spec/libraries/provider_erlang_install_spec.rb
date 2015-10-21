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

describe Chef::Provider::ErlangInstall do
  let(:version) { '18.1' }
  let(:node) { stub_node(platform: 'ubuntu', version: '14.04') }
  let(:run_context) { Chef::RunContext.new(node, {}, nil) }
  let(:resource) do
    Chef::Resource::ErlangInstall.new(version, run_context)
  end

  let(:execute) { double(Chef::Resource::Execute) }

  describe '#install_kerl' do
    before do
      allow(Chef::Resource::RemoteFile)
        .to receive(:new).with('kerl', run_context).and_return(execute)
    end

    it 'installs kerl' do
      expect(execute).to receive(:source)
        .with('https://raw.githubusercontent.com/spawngrid/kerl/master/kerl')
      expect(execute).to receive(:path).with(%r{.*/kerl$})
      expect(execute).to receive(:mode).with('0755')
      expect(execute).to receive(:run_action).with(:create)
      Chef::Provider::ErlangInstall.new(resource, run_context).send(:install_kerl)
    end
  end

  describe '#activate_kerl' do
    before do
      allow(Chef::Resource::Execute)
        .to receive(:new).with('update_releases', run_context).and_return(execute)
    end

    it 'activates kerl' do
      expect(execute).to receive(:command).with(%r{.*/kerl update releases$})
      expect(execute).to receive(:run_action).with(:run)
      Chef::Provider::ErlangInstall.new(resource, run_context).send(:activate_kerl)
    end
  end

  describe '#build_erlang' do
    before do
      allow(Chef::Resource::Execute)
        .to receive(:new).with('build_kerl_' + version, run_context).and_return(execute)
    end

    it 'builds erlang' do
      expect(execute).to receive(:command).with(%r{.*/kerl build #{version} #{version}$})
      expect(execute).to receive(:run_action).with(:run)
      Chef::Provider::ErlangInstall.new(resource, run_context).send(:build_erlang)
    end
  end

  describe '#install_erlang' do
    before do
      allow(Chef::Resource::Execute)
        .to receive(:new).with('install_kerl_' + version, run_context).and_return(execute)
    end

    context 'default prefix directory' do
      let(:prefix) { '/usr/local' }

      it 'installs at prefix directory' do
        expect(execute).to receive(:command)
          .with(%r{.*/kerl install #{version} #{prefix}/erlang/#{version}$})
        expect(execute).to receive(:run_action).with(:run)
        Chef::Provider::ErlangInstall.new(resource, run_context).send(:install_erlang)
      end
    end

    context 'configured prefix directory' do
      let(:prefix) { '/some/interesting/path' }
      let(:resource) do
        r = Chef::Resource::ErlangInstall.new(version, run_context)
        r.prefix prefix
        r
      end

      it 'installs at prefix directory' do
        expect(execute).to receive(:command)
          .with(%r{.*/kerl install #{version} #{prefix}/erlang/#{version}$})
        expect(execute).to receive(:run_action).with(:run)
        Chef::Provider::ErlangInstall.new(resource, run_context).send(:install_erlang)
      end
    end
  end
end
