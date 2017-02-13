
#########################################################################
# Basic Install with Execution
#########################################################################
rust_install '1.15.1'

project_path = ::File.join(Chef::Config[:file_cache_path], 'fake')

rust_execute 'cargo new fake' do
  version '1.15.1'
  cwd Chef::Config[:file_cache_path]
  not_if { ::File.exist?(project_path) }
end

file ::File.join(project_path, 'Cargo.toml') do
  content <<-EOF
[package]
name = "fake"
version = "0.0.1"
authors = ["Fakey McFake <fake@chef.io>"]

[dependencies]
toml = "*"
  EOF
  sensitive true
  action :create
end

rust_execute 'cargo build' do
  version '1.15.1'
  cwd project_path
end

#########################################################################
# Non-default Prefix
#########################################################################
alternate_prefix = if Chef::Platform.windows?
                     'C:/rust'
                   else
                     '/usr/local'
                   end

rust_install '2015-07-31' do
  channel 'beta'
  prefix alternate_prefix
end

#########################################################################
# Channel Attribute
#########################################################################
rust_install '2015-10-03' do
  channel 'nightly'
end
