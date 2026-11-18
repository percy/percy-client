# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'percy/client/version'

Gem::Specification.new do |spec|
  spec.name          = 'percy-client'
  spec.version       = Percy::Client::VERSION
  spec.authors       = ['Perceptual Inc.']
  spec.email         = ['team@percy.io']
  spec.summary       = 'Percy::Client'
  spec.description   = ''
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.6'

  # Faraday 0.15.4 through 2.x is supported (Faraday < 0.17.4 itself does not load on Ruby 3).
  # faraday-excon provides the excon adapter on Faraday 2; it is only required there.
  spec.add_dependency 'faraday', '>= 0.15.4', '< 3'
  spec.add_dependency 'faraday-excon', '>= 1.1', '< 3'
  spec.add_dependency 'excon', '>= 0.105.0', '< 2'
  spec.add_dependency 'addressable', '~> 2.3'
  # logger leaves Ruby's default gems in 3.5.
  spec.add_dependency 'logger'

  spec.add_development_dependency 'bundler', '>= 1.17'
  spec.add_development_dependency 'rake', '>= 12.3', '< 14'
  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'
end
