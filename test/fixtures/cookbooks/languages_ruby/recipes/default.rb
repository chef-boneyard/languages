include_recipe 'chef-sugar::default'
include_recipe 'languages::default'

ruby_install '2.1.7'

ruby_install '2.1.5' do
  prefix '/usr/local/my_ruby'
end

ruby_execute 'gem install thor' do
  prefix '/usr/local/my_ruby'
  version '2.1.5'
end

directory '/tmp'

gemfile = '/tmp/Gemfile'
file gemfile do
  content <<EOF
source 'https://rubygems.org'
gem 'nokogiri'
EOF
  action :create
end

ruby_execute 'bundle install' do
  prefix '/usr/local/my_ruby'
  version '2.1.5'
  environment 'BUNDLE_GEMFILE' => gemfile
end
