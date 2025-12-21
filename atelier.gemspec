Gem::Specification.new do |s|
  s.name        = 'atelier'
  s.summary     = 'Ruby task'
  s.description = 'A simple ruby framework to structure helper scripts'
  s.authors     = ['Thomas DE BONA']
  s.email       = 'thomas.debona@gmail.com'

  s.version     = '0.0.0'
  s.date        = '2013-11-17'

  s.files       = Dir['{lib}/**/*.rb', 'bin/*', '*.md']
  s.executables = Dir['bin/*'].collect { |executable| File.basename(executable) }

  s.add_dependency 'logger'

  s.homepage    = 'http://rubygems.org/gems/atelier'
  s.license     = 'MIT'
end
