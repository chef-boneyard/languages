require 'chefspec'
require 'chef/sugar'

# load all libraries for testing
Dir['libraries/*.rb'].each { |f| require_relative "../#{f}" }

RSpec.configure do |config|
  # Guard against people using deprecated RSpec syntax
  config.raise_errors_for_deprecations!

  # Why aren't these the defaults?
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  # Be random!
  config.order = 'random'
end

RSpec.shared_context :resource_boilerplate do
  let(:node) { stub_node(platform: 'ubuntu', version: '12.04') }
  let(:run_context) { Chef::RunContext.new(node, {}, nil) }
end

RSpec.shared_examples :language_resource do
  include_context :resource_boilerplate

  before { subject.version(version) }

  it 'has the correct default prefix' do
    expect(subject.prefix).to eq("/opt/languages/#{language}/#{version}")
  end

  it 'properly sets the version' do
    expect(subject.version).to eq(version)
  end

  context 'when a prefix is provided' do
    let(:prefix) { '/usr/local' }

    before { subject.prefix(prefix) }

    it 'sets the prefix to the requested path' do
      expect(subject.prefix).to eq(prefix)
    end
  end

  context 'on Windows' do
    before do
      allow(ENV).to receive(:[]).with('SYSTEMDRIVE').and_return('C:')
      allow(Chef::Platform).to receive(:windows?).and_return(true)
    end

    it 'has the correct default prefix' do
      expect(subject.prefix).to eq("C:/languages/#{language}/#{version}")
    end
  end
end

RSpec.shared_examples :language_execute_provider do
  describe '#environment' do
    it 'returns a Hash' do
      expect(subject.environment).to be_a(Hash)
    end

    it 'prepends PATH with the version specific langage bin dir' do
      expect(subject.environment['PATH']).to match(%r{^\/opt\/languages\/#{language}\/#{version}\/bin})
    end

    context 'on Windows' do
      before do
        allow(ENV).to receive(:[]).with('SYSTEMDRIVE').and_return('C:')
        allow(ENV).to receive(:[]).with('PATH').and_call_original
        allow(Chef::Platform).to receive(:windows?).and_return(true)
        stub_const('File::ALT_SEPARATOR', '\\')
      end

      it 'sets Path in addition to PATH' do
        expect(subject.environment).to include('Path')
      end
    end

    context 'when a PATH is set in the provided environment' do
      let(:provided_path) { '/the/dirty/south' }
      before { resource.environment('PATH' => provided_path) }

      it 'preserves the PATH' do
        expect(subject.environment['PATH']).to include(provided_path)
      end
    end
  end

  describe '#language_path' do
    it 'appends `bin` onto the end of the prefix' do
      expect(subject.language_path).to end_with('/bin')
    end
  end
end
