include_recipe 'chef-sugar::default'
include_recipe 'languages::default'

ruby_install '2.1.7'

custom_prefix = Chef::Platform.windows? ? 'C:/usr/local/my_ruby' : '/usr/local/my_ruby'

ruby_install '2.1.6' do
  prefix custom_prefix
end

ruby_execute 'gem install thor' do
  prefix custom_prefix
  version '2.1.6'
  gem_home "#{Chef::Config[:file_cache_path]}/my_gem_cache"
end

gemfile = ::File.join(Chef::Config[:file_cache_path], 'Gemfile')

file gemfile do
  content <<EOF
source 'https://rubygems.org'
gem 'nokogiri'
EOF
  action :create
end

ruby_execute 'bundle install' do
  prefix custom_prefix
  version '2.1.6'
  gem_home "#{Chef::Config[:file_cache_path]}/my_gem_cache"
  environment(
    'BUNDLE_GEMFILE' => gemfile,
    'PATH' => ENV['PATH'],
  )
end

tmp_file = ::File.join(Chef::Config[:file_cache_path], 'bundle_show_output')

ruby_execute "bundle show nokogiri > #{tmp_file}" do
  prefix custom_prefix
  version '2.1.6'
  gem_home "#{Chef::Config[:file_cache_path]}/my_gem_cache"
  environment(
    'BUNDLE_GEMFILE' => gemfile,
    'PATH' => ENV['PATH'],
  )
end
