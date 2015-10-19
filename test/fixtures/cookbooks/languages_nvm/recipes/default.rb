include_recipe 'chef-sugar::default'
include_recipe 'languages::default'

nvm 'install node v4.1.2' do
  node_version 'v4.1.2'
end
