Gem::Specification.new do |s|
  s.name        = 'rask'
  s.summary     = 'Ruby task'
  s.description = 'A simple ruby task'
  s.authors     = ['Thomas DE BONA']
  s.email       = 'thomas.debona@gmail.com'

  s.version     = '0.0.0'
  s.date        = '2013-11-17'

  s.files       = Dir['{lib}/**/*.rb', 'bin/*', '*.md']
  s.executables = Dir['bin/*'].collect { |executable| File.basename(executable) }

  s.homepage    = 'http://rubygems.org/gems/rask'
  s.license     = 'MIT'
end
