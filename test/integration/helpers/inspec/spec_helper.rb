require 'pathname'
require 'tmpdir'

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |file| require_relative(file) }

def windows?
  os[:family] == 'windows'
end

def default_prefix_base
  if windows?
    'C:/languages'
  else
    '/opt/languages'
  end
end

def chef_file_cache
  if windows?
    'C:/Users/vagrant/AppData/Local/Temp/kitchen/cache'
  else
    '/tmp/kitchen/cache'
  end
end
