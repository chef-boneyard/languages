
#########################################################################
# Basic Install with Execution
#########################################################################
node_install 'v4.1.2'

file '/tmp/package.json' do
  content <<-EOH.gsub(/^ {10}/, '')
  {
    "name": "node-js-sample",
    "version": "0.0.1",
    "description": "A sample Node.js app using Express 4",
    "dependencies": {
      "express": "^4.13.3"
    }
  }
  EOH
end

node_execute 'npm install' do
  cwd '/tmp'
  prefix '/opt/languages/node/v4.1.2'
  version 'v4.1.2'
end

#########################################################################
# Non-default Prefix
#########################################################################
node_install 'v0.10.10' do
  prefix '/usr/local'
end
