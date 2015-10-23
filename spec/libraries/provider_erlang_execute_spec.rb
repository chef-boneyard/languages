require 'chef'
require 'spec_helper'

describe Chef::Provider::ErlangExecute do
  let(:command) { 'FOO' }
  let(:run_context) { Chef::RunContext.new(node, {}, nil) }
  let(:node) { stub_node(platform: 'ubuntu', version: '12.04') }
  let(:version) { '18.1' }
  let(:prefix) { '/usr/local' }
  # let(:environment) do
  #   {
  #     'FOO' => 'BAR',
  #   }
  # end
  let(:execute) { double }

  describe '#execute' do
    let(:resource) do
      r = Chef::Resource::ErlangExecute.new(command, run_context)
      r.prefix prefix
      r.version version
      r
    end

    before do
      allow(Chef::Resource::Execute)
        .to receive(:new).with("Running erlang command '#{command}'", run_context).and_return(execute)
    end

    it 'executes command' do
      provider = Chef::Provider::ErlangExecute.new(resource, run_context)
      expect(execute).to receive(:command).with(command)
      expect(execute).to receive(:environment)
      expect(execute).to receive(:sensitive).with(false)
      expect(execute).to receive(:run_action).with(:run)
      expect(provider.send(:execute)).to eq(nil)
    end
  end
end
