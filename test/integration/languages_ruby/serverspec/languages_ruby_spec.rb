require_relative '../../../kitchen/data/spec_helper'

describe file '/opt/rubies/ruby-2.1.7/bin/ruby' do
  it { should exist }
end

describe file '/usr/local/my_ruby/ruby-2.1.5/bin/ruby' do
  it { should exist }
end

describe command('/opt/rubies/ruby-2.1.7/bin/bundler --version') do
  its(:exit_status) { should eq 0 }
end

describe command('/usr/local/my_ruby/ruby-2.1.5/bin/bundler --version') do
  its(:exit_status) { should eq 0 }
end

describe command("GEM_HOME='/tmp/kitchen/cache/my_gem_cache' /usr/local/my_ruby/ruby-2.1.5/bin/gem which thor") do
  its(:exit_status) { should eq 0 }
end

describe command("BUNDLE_GEMFILE='/tmp/kitchen/cache/Gemfile' GEM_HOME='/tmp/kitchen/cache/my_gem_cache' /usr/local/my_ruby/ruby-2.1.5/bin/bundle list") do
  its(:stdout) { should match 'nokogiri' }
end

# verify that gem_home was respected
describe file('/tmp/bundle_show_output') do
  its(:content) { should match %r{/tmp\/kitchen\/cache\/my_gem_cache\/gems\/nokogiri} }
end
