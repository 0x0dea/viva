$:.unshift File.expand_path '../lib', __FILE__
require 'viva/version'

Gem::Specification.new do |s|
  s.name        = 'viva'
  s.version     = Viva::VERSION
  s.author      = 'D.E. Akers'
  s.email       = '0x0dea@gmail.com'

  s.summary     = 'Viva exposes the virtual variable API to Ruby land.'
  s.homepage    = 'https://github.com/0x0dea/viva'
  s.license     = 'WTFPL'

  s.files       = `git ls-files`.split
  s.extensions  = %w[ext/viva/extconf.rb Rakefile]
end
