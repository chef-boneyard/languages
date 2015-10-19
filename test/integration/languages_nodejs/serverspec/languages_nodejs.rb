require 'serverspec'
require 'pathname'
require 'tmpdir'

require_relative 'spec_helper'

nodejs_path = '/usr/local/bin/node'

describe 'node' do
  describe command("#{nodejs_path} --version") do
    its(:stdout) { should match 'v4.1.2' }
  end
end
