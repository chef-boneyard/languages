include_recipe 'chef-sugar::default'
include_recipe 'languages::default'

ruby_install '2.1.7'

ruby_install '2.1.5' do
  prefix '/usr/local/my_ruby'
end
