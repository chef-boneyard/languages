require 'serverspec'
require 'pathname'
require 'tmpdir'

def windows?
  return !(/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM).nil?
end

def join_path(*args)
  ::File.expand_path(::File.join(args)).gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR)
end

if windows?
  set :backend, :cmd
  set :os, family: 'windows'
else
  set :backend, :exec
  set :path, '/sbin:/usr/local/sbin:/usr/bin:/bin'
end

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |file| require_relative(file) }