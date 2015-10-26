include_recipe 'chef-sugar::default'
include_recipe 'languages::default'

# default
erlang_install '18.1'

# test prefix param
directory '/opt/languages'

erlang_install '18.0' do
  prefix '/opt/languages'
end

# test erlang_execute
erlang_execute "erl --version erl -eval \'erlang:display(erlang:system_info(otp_release)), halt().\'  -noshell > /tmp/erlang_version" do
  prefix '/usr/local'
  version '18.1'
  environment('PATH' => ENV['PATH'])
end
