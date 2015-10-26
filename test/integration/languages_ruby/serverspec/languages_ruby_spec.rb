require_relative '../../../kitchen/data/spec_helper'

def suffix(prog)
  if windows?
    prog == 'ruby' ? 'ruby.exe' : prog + '.bat'
  else
    prog
  end
end

context 'testing ruby_install on default prefix' do
  prefix = windows? ? join_path(ENV['SYSTEMDRIVE'], 'rubies') : '/opt/rubies'
  ruby_bin_path = join_path(prefix, 'ruby-2.1.7', 'bin')

  describe file join_path(ruby_bin_path, suffix('ruby')) do
    it { should exist }
  end

  describe command(join_path(ruby_bin_path, suffix('bundler')) + ' --version') do
    let(:path) { ruby_bin_path }
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match 'Bundler' }
  end
end

context 'testing ruby_install on alternate prefix' do
  prefix = windows? ? join_path(ENV['SYSTEMDRIVE'], 'usr/local/my_ruby') : '/usr/local/my_ruby'
  ruby_bin_path = join_path(prefix, 'ruby-2.1.5', 'bin')

  describe file join_path(ruby_bin_path, suffix('ruby')) do
    it { should exist }
  end

  describe command(join_path(ruby_bin_path, suffix('bundler')) + ' --version') do
    let(:path) { ruby_bin_path }
    its(:exit_status) { should eq 0 }
  end

  describe command(join_path(ruby_bin_path, suffix('gem')) + ' which thor') do
    let(:path) { ruby_bin_path }
    its(:exit_status) { should eq 0 }
  end

  describe command(join_path(ruby_bin_path, suffix('bundle')) + ' list') do
    let(:path) { ruby_bin_path }
    let(:pre_command) do
      if windows?
        '$env:BUNDLE_GEMFILE = "$env:TEMP\\kitchen\\cache\\Gemfile"'
      else
        'BUNDLE_GEMFILE=/tmp/kitchen/cache/Gemfile'
      end
    end

    its(:stdout) { should match 'nokogiri' }
  end
end

# verify that gem_home was respected
describe file('/tmp/bundle_show_output') do
  its(:content) { should match %r{/tmp\/kitchen\/cache\/my_gem_cache\/gems\/nokogiri} }
end