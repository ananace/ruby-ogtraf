Gem::Specification.new do |s|
  s.name          = 'OGTraf'
  s.version       = '0.0.1'
  s.summary       = 'Östgötatrafiken'
  s.description   = 'Allows querying Östgötatrafiken\'s APIs'
  s.author        = 'Alexander "Ace" Olofsson'
  s.email         = 'ace@haxalot.com'
  s.license       = 'MIT'

  s.files         = Dir['{bin,lib}/**/*']
  s.executables << 'ogtraf'

  s.require_paths = ['lib']

  s.add_dependency 'logging', '~> 2'

  s.add_runtime_dependency 'thor', '~> 0.20'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'simplecov'
end
