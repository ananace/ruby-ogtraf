Gem::Specification.new do |s|
  s.name          = 'OGTraf'
  s.version       = '0.0.1'
  s.summary       = 'Östgötatrafiken'
  s.description   = 'Allows querying Östgötatrafiken\'s APIs'
  s.author        = 'Alexander "Ace" Olofsson'
  s.email         = 'ace@haxalot.com'
  s.license       = 'MIT'

  s.files         = Dir[ 'bin/*', 'lib/**/*' ]
  s.executables   << 'ogtraf'

  s.require_paths = [ 'lib' ]
end
