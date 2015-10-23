include_recipe 'chef-sugar::default'
include_recipe 'languages::default'

directory '/opt/languages'

erlang_install '18.1' do
  prefix '/opt/languages'
end
