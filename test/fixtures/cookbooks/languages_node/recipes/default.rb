
node_install 'v4.1.2'

node_install 'v0.10.10' do
  prefix '/usr/local'
end

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

# Exercise run_state
node_execute 'npm install' do
  cwd '/tmp'
  prefix '/opt/languages/node/v4.1.2'
  version 'v4.1.2'
end
