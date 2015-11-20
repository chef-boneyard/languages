require 'spec_helper'

stable_prefix_rust    = File.join(default_prefix_base, 'rust', '1.3.0')
alternate_prefix_rust = windows? ? 'C:/rust' : '/usr/local'
nightly_prefix_rust   = File.join(default_prefix_base, 'rust', '2015-10-03')

describe command(File.join(stable_prefix_rust, 'bin', 'rustc') + ' --version') do
  its(:stdout) { should match '1.3.0' }
end

describe command(File.join(alternate_prefix_rust, 'bin', 'rustc') + ' --version') do
  its(:stdout) { should match '2015-07-31' }
end

describe command(File.join(nightly_prefix_rust, 'bin', 'rustc') + ' --version') do
  its(:stdout) { should match '2015-10-03' }
end

describe file("#{chef_file_cache}/fake/target/debug/libfake.rlib") do
  it { should be_file }
end

describe file("#{chef_file_cache}/fake/Cargo.lock") do
  its(:content) { should match 'regex' }
end
