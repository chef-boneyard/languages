
#########################################################################
# Basic Install with Execution
#########################################################################
erlang_install '18.1'

erlang_execute "erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell > /tmp/erlang_version" do
  version '18.1'
end

#########################################################################
# Non-default Prefix
#########################################################################
erlang_install '18.0' do
  prefix '/usr/local'
end
