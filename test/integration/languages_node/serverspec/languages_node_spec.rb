require_relative '../../../kitchen/data/spec_helper'

describe 'node v4.1.2' do
  nvm_path = '/usr/local/bin/nvm'
  node_version = 'v4.1.2'
  describe file("#{nvm_path}/versions/node/#{node_version}/bin") do
    it { should be_directory }
  end

  describe command("#{nvm_path}/versions/node/#{node_version}/bin/node --version") do
    its(:stdout) { should match node_version }
  end
end

describe 'node v0.10.10' do
  nvm_path = '/opt/nvm'
  node_version = 'v0.10.10'
  describe file("#{nvm_path}/#{node_version}/bin") do
    it { should be_directory }
  end

  describe command("#{nvm_path}/#{node_version}/bin/node --version") do
    its(:stdout) { should match node_version }
  end
end
