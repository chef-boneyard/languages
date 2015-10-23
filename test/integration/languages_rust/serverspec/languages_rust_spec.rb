require 'serverspec'
require 'pathname'
require 'tmpdir'

require_relative 'spec_helper'

rust_path = if os[:family] == 'windows'
              '& "C:\Program Files\Rust nightly 1.5\bin\rustc"'
            else
              '/usr/local/bin/rustc'
            end

describe 'rustc' do
  describe command("#{rust_path} --version") do
    its(:stdout) { should match '2015-10-03' }
  end
end

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
