
#########################################################################
# Basic Install with Execution
#########################################################################
erlang_install '19.2'

erlang_execute "erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell > /tmp/erlang_version" do
  version '19.2'
end

#########################################################################
# Non-default Prefix
#########################################################################
erlang_install '19.1' do
  prefix '/usr/local/erlang'
end
