#########################################################################
# Basic Install with Execution (default GOPATH)
#########################################################################
go_install '1.5.2'

go_execute 'go get -u github.com/golang/example/hello' do
  version '1.5.2'
end

# used for verifcation
go_execute 'go version > /tmp/version-1.5.2' do
  version '1.5.2'
end

# example for execute
execute '/opt/languages/go/1.5.2/bin/go version > /tmp/version-1.5.2-execute' do
  environment('GOROOT' => '/opt/languages/go/1.5.2')
end

#########################################################################
# Non-default Prefix
#########################################################################
if Chef::Platform.windows?
  alternate_prefix = 'C:/rust'
else
  alternate_prefix = '/usr/local'
end

go_install '1.6beta1' do
  prefix alternate_prefix
end

# used for verifcation
go_execute 'go version > /tmp/version-1.6beta1' do
  version '1.6beta1'
  prefix alternate_prefix
end

# Non-default GOPATH
gopath = ::File.join(Chef::Config[:file_cache_path], 'gopath')
go_execute 'go get -u github.com/golang/example/hello' do
  go_path gopath
  version '1.5.2'
end
