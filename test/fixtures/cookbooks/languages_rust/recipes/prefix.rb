include_recipe 'chef-sugar::default'
include_recipe 'languages::default'

package 'curl' unless mac_os_x?

directory '/opt/rust'

rust_install '2015-10-03' do
  channel 'nightly'
  prefix  '/opt/rust'
end
