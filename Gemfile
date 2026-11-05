source 'https://rubygems.org'

gem 'openvox', ENV.fetch('OPENVOX_GEM_VERSION', '~> 8.0'), require: false
gem 'voxpupuli-test', '~> 15.0', require: false
# jgrep (via facterdb) calls JSON.create_id=, removed in json 3.0
gem 'json', '< 3', require: false

group :integration do
  gem 'kitchen-docker', require: false
  gem 'kitchen-puppet', require: false
  gem 'kitchen-verifier-serverspec', require: false
  gem 'librarian-puppet', require: false
  gem 'test-kitchen', require: false
end
