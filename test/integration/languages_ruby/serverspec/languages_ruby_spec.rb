require 'serverspec'
require 'pathname'
require 'tmpdir'

require_relative 'spec_helper'

describe file '/opt/rubies/ruby-2.1.7/bin/ruby' do
  it { should exist }
end
