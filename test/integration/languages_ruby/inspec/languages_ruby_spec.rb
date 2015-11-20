require 'spec_helper'

default_prefix_ruby   = File.join(default_prefix_base, 'ruby', '2.1.7')
alternate_prefix_ruby = windows? ? 'C:/ruby' : '/usr/local'

describe command(File.join(default_prefix_ruby, 'bin', 'ruby') + ' --version') do
  its(:stdout) { should match '2.1.7' }
end

describe command(File.join(default_prefix_ruby, 'bin', 'bundle') + ' --version') do
  its(:exit_status) { should eq 0 }
end

describe command(File.join(alternate_prefix_ruby, 'bin', 'ruby') + ' --version') do
  its(:stdout) { should match '2.1.5' }
end

describe command(File.join(alternate_prefix_ruby, 'bin', 'bundle') + ' --version') do
  its(:exit_status) { should eq 0 }
end

describe file("#{chef_file_cache}/bundle_show_output") do
  its(:content) { should match(/nokogiri/) }
end

describe file("#{chef_file_cache}/gem_which_nokogiri_output") do
  its(:content) { should match(/^#{default_prefix_ruby}.*nokogiri\.rb/) }
end

describe file("#{chef_file_cache}/gem_which_thor_output") do
  its(:content) { should match(%r{^#{chef_file_cache}\/my_gem_cache\/gems.*thor\.rb}) }
end
