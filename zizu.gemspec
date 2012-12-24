# -*- encoding: utf-8 -*-                                                       
require File.expand_path('../lib/zizu/version', __FILE__)

Gem::Specification.new do |gem|

  gem.name		        = "zizu"
  gem.platform        = Gem::Platform::RUBY
  gem.version		      = Zizu::VERSION
  gem.license     	  = "MIT"
  gem.date        	  = "2012-12-23"
  gem.summary     	  = "zizu cli"
  gem.description 	  = "Static site generator and deployment tool."
  gem.authors     	  = %w(stephenhu)
  gem.email       	  = "epynonymous@outlook.com"
  gem.homepage    	  = "http://github.com/stephenhu/zizu"

  gem.require_paths   = %w(lib)
  gem.bindir          = "bin"
  gem.files           = `git ls-files`.split($\)                                  
  #gem.executables     = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.executables     = %w(zizu)

  #gem.add_dependency  "rgit"

end

