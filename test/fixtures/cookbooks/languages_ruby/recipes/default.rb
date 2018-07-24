
#########################################################################
# Basic Install with Execution
#########################################################################
ruby_install '2.1.7'

gemfile = ::File.join(Chef::Config[:file_cache_path], 'Gemfile')

file gemfile do
  content <<-EOF
source 'https://rubygems.org'
gem 'nokogiri'
EOF
  action :create
end

ruby_execute 'bundle install' do
  version '2.1.7'
  environment(
    'BUNDLE_GEMFILE' => gemfile
  )
end

# Perform some checks with ruby_execute since ServerSpec's Windows support
# is shaky at best. It's easier to read these files in our tests as opposed
# to attempting to execute the commands and match on STDOUT.

bundle_output_path = ::File.join(Chef::Config[:file_cache_path], 'bundle_show_output')

ruby_execute "bundle show  > #{bundle_output_path}" do
  version '2.1.7'
  environment(
    'BUNDLE_GEMFILE' => gemfile
  )
end

gem_which_output = ::File.join(Chef::Config[:file_cache_path], 'gem_which_nokogiri_output')

ruby_execute "gem which nokogiri > #{gem_which_output}" do
  version '2.1.7'
  environment(
    'BUNDLE_GEMFILE' => gemfile
  )
end

#########################################################################
# Non-default Prefix
#########################################################################
alternate_prefix = if Chef::Platform.windows?
                     'C:/ruby'
                   else
                     '/usr/local'
                   end

ruby_install '2.1.5' do
  prefix alternate_prefix
end

ruby_execute 'gem install thor' do
  prefix alternate_prefix
  gem_home "#{Chef::Config[:file_cache_path]}/my_gem_cache"
end

gem_which_output = ::File.join(Chef::Config[:file_cache_path], 'gem_which_thor_output')

ruby_execute "gem which thor > #{gem_which_output}" do
  prefix alternate_prefix
  gem_home "#{Chef::Config[:file_cache_path]}/my_gem_cache"
end
