include_recipe 'chef-sugar::default'
include_recipe 'languages::default'

node_install 'v4.1.2'

# Exercise changing prefixes
node_install 'v0.10.10'

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
  version 'v4.1.2'
end
