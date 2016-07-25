Gem::Specification.new do |s|
  s.name          = 'OGTraf'
  s.version       = '0.0.1'
  s.summary       = 'Östgötatrafiken'
  s.description   = 'Allows querying Östgötatrafiken\'s APIs'
  s.author        = 'Alexander "Ace" Olofsson'
  s.email         = 'ace@haxalot.com'
  s.license       = 'MIT'

  s.files         = Dir['bin/*', 'lib/**/*']
  s.executables << 'ogtraf'

  s.require_paths = ['lib']

  s.add_runtime_dependency 'thor', '~> 0.19'

  s.add_development_dependency 'bundler', '~> 1.12'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rubocop', '~> 0.41'
end
