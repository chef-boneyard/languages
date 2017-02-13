require 'spec_helper'

describe file '/opt/languages/erlang/19.2/releases/19/OTP_VERSION' do
  it { should exist }
  its(:content) { should match '19.2' }
end

describe file '/usr/local/erlang/releases/19/OTP_VERSION' do
  it { should exist }
  its(:content) { should match '19.1' }
end

describe file '/tmp/erlang_version' do
  it { should exist }
  its(:content) { should match '19' }
end
