require_relative '../../../kitchen/data/spec_helper'

nvm_path = '/opt/languages/node'

describe 'node v4.1.2' do
  node_version = 'v4.1.2'
  describe file("#{nvm_path}/#{node_version}/bin") do
    it { should be_directory }
  end

  describe command("#{nvm_path}/#{node_version}/bin/node --version") do
    its(:stdout) { should match node_version }
  end
end

describe 'node v0.10.10' do
  node_version = 'v0.10.10'
  describe file("#{nvm_path}/#{node_version}/bin") do
    it { should be_directory }
  end

  describe command("#{nvm_path}/#{node_version}/bin/node --version") do
    its(:stdout) { should match node_version }
  end
end

describe 'node_execute npm install' do
  describe file('/tmp/package.json') do
    it { should exist }
  end

  describe file('/tmp/node_modules') do
    it { should be_directory }
  end
end
