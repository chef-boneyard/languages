source 'https://supermarket.chef.io'

metadata

def fixture(name)
  cookbook "languages_#{name}", path: "test/fixtures/cookbooks/languages_#{name}"
end

group :integration do
  cookbook 'apt'
  cookbook 'yum-epel'
  fixture  'rust'
  fixture  'ruby'
  fixture  'nvm'
  fixture  'nodejs'
end
