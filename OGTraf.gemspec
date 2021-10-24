# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name          = 'OGTraf'
  s.version       = '0.0.1'
  s.summary       = 'Östgötatrafiken'
  s.description   = 'Allows querying Östgötatrafiken\'s APIs'
  s.author        = 'Alexander "Ace" Olofsson'
  s.email         = 'ace@haxalot.com'
  s.license       = 'MIT'

  s.required_ruby_version = '>= 2.5.0'

  s.files         = Dir['{bin,lib}/**/*']
  s.require_paths = ['lib']
  s.executables << 'ogtraf'

  s.add_dependency 'logging', '~> 2'

  s.add_runtime_dependency 'thor', '~> 1'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'simplecov'
end
