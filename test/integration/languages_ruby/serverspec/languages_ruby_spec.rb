require 'serverspec'
require 'pathname'
require 'tmpdir'

require_relative 'spec_helper'

describe file '/opt/rubies/ruby-2.1.7/bin/ruby' do
  it { should exist }
end

describe file '/usr/local/my_ruby/bin/ruby' do
  it { should exist }
end

describe command('/opt/rubies/ruby-2.1.7/bin/bundler --version') do
  its(:exit_status) { should eq 0 }
end

describe command('/usr/local/my_ruby/bin/bundler --version') do
  its(:exit_status) { should eq 0 }
end
