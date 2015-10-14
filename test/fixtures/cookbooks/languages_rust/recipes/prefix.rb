include_recipe 'chef-sugar::default'
include_recipe 'languages::default'

package 'curl' unless mac_os_x? || windows?

if windows?
  install_dir = 'C:/Program Files/Opt'
else
  install_dir = '/opt/rust'
end

directory install_dir

rust_install '2015-10-03' do
  channel 'nightly'
  prefix  install_dir
end
