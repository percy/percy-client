source 'https://rubygems.org'

# Specify your gem's dependencies in percy-client.gemspec
gemspec

# Development/CI only: this Gemfile is not part of the published gem. Consumers get only the
# gemspec's dependencies.

# Lets the CI matrix test one faraday line at a time (e.g. FARADAY_VERSION='0.15.4' or '~> 2.0').
# The gemspec allows >= 0.15.4, < 3, and without this Bundler would always pick the newest
# faraday, so the old versions prod still runs would never be tested. Unset: no extra constraint.
gem 'faraday', ENV['FARADAY_VERSION'] unless ENV['FARADAY_VERSION'].to_s.empty?

# Rubocop rules used by .rubocop.yml. Moved here from the gemspec: percy-style pins rubocop 0.x,
# which does not run on Ruby 3.x, so it is installed (and lint runs) on Ruby 2.x only.
gem 'percy-style', '~> 0.5.0', require: false if RUBY_VERSION < '3'

gem 'guard-rspec', require: false

group :test, :development do
  gem 'pry'
end
