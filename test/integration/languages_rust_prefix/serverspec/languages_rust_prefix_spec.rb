require 'serverspec'
require 'pathname'
require 'tmpdir'

set :backend, :exec

describe 'rustc' do
  describe file('/opt/rust/bin/rustc') do
    it { should exist }
  end

  describe command('LD_LIBRARY_PATH=/opt/rust/lib /opt/rust/bin/rustc --version') do
    its(:stdout) { should match '2015-08-16' }
  end
end
