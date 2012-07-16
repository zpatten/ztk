# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ztk/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Zachary Patten"]
  gem.email         = ["zachary@jovelabs.com"]
  gem.description   = %q{Zachary's Toolkit}
  gem.summary       = %q{Contains various helper classes and utility methods I find I regularly need.}
  gem.homepage      = "http://www.github.com/jovelabs"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ztk"
  gem.require_paths = ["lib"]
  gem.version       = ZTK::VERSION
end
