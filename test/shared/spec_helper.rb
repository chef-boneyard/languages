require 'serverspec'
require 'pathname'
require 'tmpdir'

if (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM).nil?
  set :backend, :exec
else
  set :backend, :cmd
  set :os, family: 'windows'
end

set :path, '/sbin:/usr/local/sbin:/usr/bin:/bin'

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |file| require_relative(file) }
