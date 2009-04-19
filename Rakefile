require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'time'
require 'date'

PROJECT_SPECS = Dir['spec/**/*.rb']
PROJECT_MODULE = 'Makura'

GEMSPEC = Gem::Specification.new{|s|
  s.name         = 'makura'
  s.author       = "Michael 'manveru' Fellinger"
  s.summary      = "Ruby wrapper around the CouchDB REST API."
  s.description  = "Ruby wrapper around the CouchDB REST API."
  s.email        = 'm.fellinger@gmail.com'
  s.homepage     = 'http://github.com/manveru/makura'
  s.platform     = Gem::Platform::RUBY
  s.version      = (ENV['PROJECT_VERSION'] || Date.today.strftime("%Y.%m.%d"))
  s.files        = `git ls-files`.split("\n").sort
  s.has_rdoc     = true
  s.require_path = 'lib'
  s.executables = ['makura']
  s.bindir = "bin"

  s.add_runtime_dependency('rest-client', '>= 0.8.1')
}

Dir['tasks/*.rake'].each{|f| import(f) }

task :default => [:bacon]

CLEAN.include('')
