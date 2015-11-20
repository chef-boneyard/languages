require 'spec_helper'

describe command('/opt/languages/node/v4.1.2/bin/node --version') do
  its(:stdout) { should match 'v4.1.2' }
end

describe command('/usr/local/bin/node --version') do
  its(:stdout) { should match 'v0.10.10' }
end

describe file('/tmp/node_modules/express') do
  it { should be_directory }
end
