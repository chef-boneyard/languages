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

describe Chef::Provider::RustInstall do
  subject { Chef::Provider::RustInstall.new(resource, run_context) }

  let(:node) { stub_node(platform: 'ubuntu', version: '14.04') }
  let(:run_context) { Chef::RunContext.new(node, {}, nil) }
  let(:resource) do
    Chef::Resource::RustInstall.new('2015-10-03', run_context)
  end

  describe '#current_rust_version' do
    context 'installed at prefix directory' do
      before do
        allow(subject).to receive(:`).with('/usr/local/bin/rustc --version').and_return('rustc 1.4.0-nightly (e822a18ae 2015-10-03)')
      end

      it 'returns the version' do
        expect(subject.send(:current_rust_version)).to match('2015-10-03')
      end
    end

    context 'not installed at prefix directory' do
      before do
        allow(subject).to receive(:`).with('/usr/local/bin/rustc --version').and_raise(Errno::ENOENT)
      end

      it 'returns NONE' do
        expect(subject.send(:current_rust_version)).to match('NONE')
      end
    end
  end

  describe '#rustup_cmd' do
    it 'defaults to a prefix of /usr/local' do
      expect(subject.send(:rustup_cmd)).to match('--prefix=/usr/local')
    end

    it 'defaults to a channel of stable' do
      expect(subject.send(:rustup_cmd)).to match('--channel=stable')
    end

    context 'override prefix' do
      let(:prefix) { '/opt/rust' }
      let(:resource) do
        r = Chef::Resource::RustInstall.new('2015-10-03', run_context)
        r.prefix(prefix)
        r
      end

      it 'sets the prefix to /opt/rust' do
        expect(subject.send(:rustup_cmd)).to match('--prefix=/opt/rust')
      end
    end

    context 'override channel' do
      let(:channel) { 'nightly' }
      let(:resource) do
        r = Chef::Resource::RustInstall.new('2015-10-03', run_context)
        r.channel(channel)
        r
      end

      it 'sets the channel to nightly' do
        expect(subject.send(:rustup_cmd)).to match('--channel=nightly')
      end
    end

    context 'on OS X' do
      before do
        allow(subject).to receive(:mac_os_x?).and_return(true)
      end

      it 'disables sudo' do
        expect(subject.send(:rustup_cmd)).to match('--disable-sudo')
      end
    end
  end

  describe '#fetch_rust_installer' do
    let(:path) { "#{Chef::Config[:file_cache_path]}/rustup.sh" }
    let(:source) { 'https://static.rust-lang.org/rustup.sh' }
    let(:remote_file_resource) do
      double(
        Chef::Resource::RemoteFile,  name:       nil,
                                     path:       nil,
                                     source:     nil,
                                     run_action: nil
      )
    end

    before do
      allow(Chef::Resource::RemoteFile).to receive(:new).and_return(remote_file_resource)
    end

    it 'fetches the rustup script' do
      expect(remote_file_resource).to receive(:source).with(source)
      subject.send(:fetch_rust_installer)
    end

    it 'fetches the remote file to the given path' do
      expect(remote_file_resource).to receive(:path).with(path)
      subject.send(:fetch_rust_installer)
    end
  end

  describe 'run_rust_installer' do
    let(:command) { 'rustup.sh' }
    let(:execute_resource) do
      double(
        Chef::Resource::Execute, name:       nil,
                                 command:    nil,
                                 run_action: nil
      )
    end

    before do
      allow(subject).to receive(:rustup_cmd).and_return('rustup.sh')
      allow(Chef::Resource::Execute).to receive(:new).and_return(execute_resource)
    end

    it 'runs the rustup script' do
      expect(execute_resource).to receive(:command).with(command)
      subject.send(:run_rust_installer)
    end
  end
end
