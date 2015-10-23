require_relative '../../../kitchen/data/spec_helper'

gemfile_path = windows? ? windows_safe_path_expand('~/AppData/Local/Temp/kitchen/cache/Gemfile') :
    '/tmp/kitchen/cache'

set :env, :BUNDLE_GEMFILE => gemfile_path

context 'testing ruby_install resource' do
  let(:default_prefix) { windows? ? ::File.join(ENV['SYSTEMDRIVE'], 'rubies') : '/opt/rubies' }
  let(:ruby_bin) { windows? ? 'ruby.exe' : 'ruby' }

  describe file windows_safe_path_join(default_prefix, 'ruby-2.1.7/bin/ruby') do
    it { should exist }
  end

  describe file "/usr/local/my_ruby/ruby-2.1.5/bin/#{ruby_bin}" do
    it { should exist }
  end

  describe command(windows_safe_path_join(default_prefix, 'ruby-2.1.7/bin/bundler') + ' --version') do
    its(:exit_status) { should eq 0 }
  end

  describe command(windows_safe_path_expand('/usr/local/my_ruby/ruby-2.1.5/bin/bundler') + ' --version') do
    its(:exit_status) { should eq 0 }
  end

  describe command(windows_safe_path_expand('/usr/local/my_ruby/ruby-2.1.5/bin/gem') + ' which thor') do
    its(:exit_status) { should eq 0 }
  end

  describe command(windows_safe_path_expand('/usr/local/my_ruby/ruby-2.1.5/bin/bundle') + ' list') do
    its(:stdout) { should match 'nokogiri' }
  end
end

# verify that gem_home was respected
describe file('/tmp/bundle_show_output') do
  its(:content) { should match %r{/tmp\/kitchen\/cache\/my_gem_cache\/gems\/nokogiri} }
end
