include_recipe 'chef-sugar::default'
include_recipe 'languages::default'

erlang_install '18.1'

directory '/opt/languages'

erlang_install '18.0' do
  prefix '/opt/languages'
end
