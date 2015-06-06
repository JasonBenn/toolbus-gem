Gem::Specification.new do |s|
  s.summary     = "To learn a tool: build projects, measure your progress with Toolbus"
  s.description = "Scans and parses clean git repos, figures out how much of an API you've used"

  s.name        = 'toolbus'
  s.version     = '0.1.1'
  s.date        = '2015-06-05'
  s.authors     = ["Jason Benn"]
  s.email       = 'jasoncbenn@gmail.com'
  s.homepage    = "http://www.jbenn.net"
  s.license     = 'MIT'

  s.files         = Dir["{bin,lib}/**/*", "README.md"]
  s.test_files    = Dir["spec/**/*"]
  s.executables = ['toolbus']
  s.require_paths = ['lib']

  s.add_runtime_dependency 'parser', '~> 2.2'
  s.add_runtime_dependency 'json_pure', '~> 1.8'
  s.add_development_dependency 'rspec', '~> 3.2'
  s.add_development_dependency 'pry', '~> 0.10'
end
