require 'serverspec'
require 'pathname'
require 'tmpdir'

require_relative 'spec_helper'

describe 'rustc', if: os[:family] != 'windows' do
  describe file('/opt/rust/bin/rustc') do
    it { should exist }
  end

  describe command('LD_LIBRARY_PATH=/opt/rust/lib /opt/rust/bin/rustc --version'), if: os[:family] != 'windows' do
    its(:stdout) { should match '2015-10-03' }
  end
end
