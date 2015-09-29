require 'serverspec'
require 'pathname'
require 'tmpdir'

set :backend, :exec

describe 'rustc' do
  describe command("/usr/local/bin/rustc --version") do
    its(:stdout) { should match '2015-08-16' }
  end
end
