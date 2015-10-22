include_recipe 'chef-sugar::default'
include_recipe 'languages::default'

node_install 'v4.1.2'

node_install 'v0.10.10' do
  prefix '/opt'
end
