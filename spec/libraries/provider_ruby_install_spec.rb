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

describe Chef::Provider::RubyInstallUnix do
  subject { Chef::Provider::RubyInstallUnix.new(resource, run_context) }

<<<<<<< HEAD
  let(:install_cmd) { "ruby-install --no-install-deps --install-dir #{prefix} --patch patch1 --patch patch2 ruby #{version} -- #{Chef::Provider::RubyInstallUnix.compile_flags}" }
=======
  let(:install_cmd) {
    "ruby-install --no-install-deps --install-dir #{prefix} --patch patch1 --patch patch2 ruby #{version} -- #{Chef::Provider::RubyInstallUnix.compile_flags}"
  }
>>>>>>> Port ruby_install from omnibus cookbook to here.

  let(:run_context) { Chef::RunContext.new(node, {}, nil) }
  let(:node) { stub_node(platform: 'ubuntu', version: '12.04') }
  let(:version) { '2.1.7' }
<<<<<<< HEAD
  let(:patches) { %w(patch1 patch2) }
  let(:prefix) { '/usr/local' }
  let(:environment) do
    {
      'FOO' => 'BAR',
=======
  let(:patches) { ['patch1', 'patch2'] }
  let(:prefix) { '/usr/local' }
  let(:environment) do
    {
      'FOO' => 'BAR'
>>>>>>> Port ruby_install from omnibus cookbook to here.
    }
  end
  let(:resource) do
    r = Chef::Resource::RubyInstall.new(version, run_context)
    r.environment(environment)
    r.patches(patches)
    r.prefix(prefix)
    r
  end

<<<<<<< HEAD
  before do
=======
  before do 
>>>>>>> Port ruby_install from omnibus cookbook to here.
    allow(subject).to receive(:install_dependencies)
    allow_any_instance_of(Chef::Resource::Execute).to receive(:run_action)
  end

<<<<<<< HEAD
  context '#install' do
    # not much to test in there beyond it getting called
    it 'calls install_dependencies' do
=======
  context "#install" do
    # not much to test in there beyond it getting called
    it "calls install_dependencies" do
>>>>>>> Port ruby_install from omnibus cookbook to here.
      expect(subject).to receive(:install_dependencies).once
      subject.send(:install)
    end

<<<<<<< HEAD
    it 'calls Resource::Execute object command method with proper input' do
=======
    it "calls Resource::Execute object command method with proper input" do
>>>>>>> Port ruby_install from omnibus cookbook to here.
      expect_any_instance_of(Chef::Resource::Execute).to receive(:command).with(install_cmd)
      subject.send(:install)
    end

<<<<<<< HEAD
    it 'calls Resource::Execute.run_action(:run)' do
=======
    it "calls Resource::Execute.run_action(:run)" do
>>>>>>> Port ruby_install from omnibus cookbook to here.
      expect_any_instance_of(Chef::Resource::Execute).to receive(:run_action).with(:run)
      subject.send(:install)
    end

<<<<<<< HEAD
    context 'when there are no patches' do
      let(:patches) { nil }
      let(:install_cmd) { "ruby-install --no-install-deps --install-dir #{prefix} ruby #{version} -- #{Chef::Provider::RubyInstallUnix.compile_flags}" }

      it 'calls Resource::Execute object command method with proper input' do
=======
    context "when there are no patches" do
      let(:patches) { nil }
      let(:install_cmd) {
        "ruby-install --no-install-deps --install-dir #{prefix} ruby #{version} -- #{Chef::Provider::RubyInstallUnix.compile_flags}"
      }

      it "calls Resource::Execute object command method with proper input" do
>>>>>>> Port ruby_install from omnibus cookbook to here.
        expect_any_instance_of(Chef::Resource::Execute).to receive(:command).with(install_cmd)
        subject.send(:install)
      end
    end
  end

<<<<<<< HEAD
  context '#version' do
    it 'returns the proper version' do
=======
  context "#version" do
    it "returns the proper version" do
>>>>>>> Port ruby_install from omnibus cookbook to here.
      expect(subject.send(:version)).to eq(version)
    end
  end

<<<<<<< HEAD
  context '#installed?' do
    context 'when the prefix exists' do
=======
  context "#installed?" do
    context "when the prefix exists" do
>>>>>>> Port ruby_install from omnibus cookbook to here.
      before do
        allow(File).to receive(:directory?).with(prefix).and_return(true)
      end

<<<<<<< HEAD
      it 'returns true' do
=======
      it "returns true" do
>>>>>>> Port ruby_install from omnibus cookbook to here.
        expect(subject.send(:installed?)).to  eq(true)
      end
    end

<<<<<<< HEAD
    context 'when the prefix does not exist' do
=======
    context "when the prefix does not exist" do
>>>>>>> Port ruby_install from omnibus cookbook to here.
      before do
        allow(File).to receive(:directory?).with(prefix).and_return(false)
      end

<<<<<<< HEAD
      it 'returns false' do
=======
      it "returns false" do
>>>>>>> Port ruby_install from omnibus cookbook to here.
        expect(subject.send(:installed?)).to eq(false)
      end
    end
  end
end
