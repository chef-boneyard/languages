require 'serverspec'
require 'pathname'
require 'tmpdir'

require_relative 'spec_helper'

library_path = if os[:family] == 'darwin'
                 'DYLD_LIBRARY_PATH'
               else
                 'LD_LIBRARY_PATH'
               end

describe 'rustc', if: os[:family] != 'windows' do
  describe file('/opt/rust/bin/rustc') do
    it { should exist }
  end

  describe command("#{library_path}=/opt/rust/lib /opt/rust/bin/rustc --version"), if: os[:family] != 'windows' do
    its(:stdout) { should match '2015-10-03' }
  end
end
