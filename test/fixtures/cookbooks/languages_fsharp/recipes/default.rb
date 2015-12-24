#########################################################################
# Basic Install with Execution
#########################################################################
fsharp_install '4.0.1.1'

project_path = ::File.join(Chef::Config[:file_cache_path], 'fake')

directory project_path

file ::File.join(project_path, 'test.fsx') do
  content <<-EOF
let toHackerTalk (phrase:string) =
    phrase.Replace('t', '7').Replace('o', '0')

let output = toHackerTalk("Lets Ship it to the world")

printfn "%s" output
EOF
  action :create
end

case node[:platform_family]
when 'rhel', 'debian'
  fsharp_execute "fsharpi #{project_path}/test.fsx" do
    version '4.0.1.1'
  end
when 'windows'
  fsharp_execute "fsi #{project_path}/test.fsx" do
    version '4.0.1.1'
  end
end

#########################################################################
# Non-default Prefix
#########################################################################
# Install time is very long, commented out for local testing
# fsharp_install '4.0.1.1' do
#   prefix '/usr/local'
# end
