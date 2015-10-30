require 'serverspec'
require 'pathname'
require 'tmpdir'

require_relative 'spec_helper'

describe file '/opt/languages/erlang/18.1/releases/18/OTP_VERSION' do
  it { should exist }
  its(:content) { should match '18.1' }
end

describe file '/usr/local/releases/18/OTP_VERSION' do
  it { should exist }
  its(:content) { should match '18.0' }
end

describe file '/tmp/erlang_version' do
  it { should exist }
  its(:content) { should match '18' }
end
