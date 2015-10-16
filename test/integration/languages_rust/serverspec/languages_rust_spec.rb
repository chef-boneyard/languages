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
