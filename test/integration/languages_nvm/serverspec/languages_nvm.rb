require 'serverspec'
require 'pathname'
require 'tmpdir'

require_relative 'spec_helper'

nvm_path = '/usr/local/bin/nvm'

describe 'nvm' do
  describe command("#{nvm_path} --version") do
    its(:stdout) { should match 'v0.29.0' }
  end
end
