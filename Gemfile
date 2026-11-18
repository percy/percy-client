source 'https://rubygems.org'

# Specify your gem's dependencies in percy-client.gemspec
gemspec

# CI matrix: narrow faraday within the gemspec range, e.g. FARADAY_VERSION='~> 2.0'.
gem 'faraday', ENV['FARADAY_VERSION'] unless ENV['FARADAY_VERSION'].to_s.empty?

# percy-style pins rubocop 0.x, which does not run on Ruby 3.x; lint runs on Ruby 2.x only.
gem 'percy-style', '~> 0.5.0', require: false if RUBY_VERSION < '3'

gem 'guard-rspec', require: false

group :test, :development do
  gem 'pry'
end
