require 'spec_helper'

default_prefix_go = File.join(default_prefix_base, 'go')

# go will only tell us its version if GOROOT is set -- its default is '/usr/local/go'
# without introducing symlinks here, we just verify that compiling programs with both
# installed versions works fine, and check the output of `go_execute 'go version'`

# alternate_prefix_go = windows? ? 'C:/go' : '/usr/local/go'
# describe command(File.join(default_prefix_go, '1.5.2', 'bin', 'go') + ' version') do
#   its(:stdout) { should match '1.5.2' }
# end

# describe command(File.join(alternate_prefix_go, 'bin', 'go') + ' version') do
#   its(:stdout) { should match '1.6beta1' }
# end

describe file('/tmp/version-1.5.2') do
  its(:content) { should match(/1\.5\.2/) }
end

describe file('/tmp/version-1.5.2-execute') do
  its(:content) { should match(/1\.5\.2/) }
end

describe file('/tmp/version-1.6beta1') do
  its(:content) { should match(/1\.6beta1/) }
end

# default gopath
describe command(File.join(default_prefix_go, 'gopath', 'bin', 'hello')) do
  its(:stdout) { should match 'Hello, Go examples!' }
end

# non-default gopath
describe command('/tmp/kitchen/cache/gopath/bin/hello') do
  its(:stdout) { should match 'Hello, Go examples!' }
end
