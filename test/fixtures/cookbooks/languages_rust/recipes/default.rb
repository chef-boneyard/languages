include_recipe 'chef-sugar::default'
include_recipe 'languages::default'

package 'curl' unless mac_os_x? || windows?

rust_install '2015-08-17' do
  channel 'nightly'
end
