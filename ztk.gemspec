lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ztk/version'

Gem::Specification.new do |gem|
  gem.authors       = ["Zachary Patten"]
  gem.email         = ["zachary@jovelabs.net"]
  gem.description   = %q{Zachary's (DevOp) Tool Kit}
  gem.summary       = %q{Contains various classes and utilities I find I regularly need.}
  gem.homepage      = "https://github.com/jovelabs/ztk"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ztk"
  gem.require_paths = ["lib"]
  gem.version       = ZTK::VERSION

  gem.add_dependency("erubis", ">= 0")
  gem.add_dependency("net-ssh", ">= 0")
  gem.add_dependency("net-sftp", ">= 0")
  gem.add_dependency("activesupport", ">= 0")

  gem.add_development_dependency("pry", ">= 0")
  gem.add_development_dependency("rake", ">= 0")
  gem.add_development_dependency("rspec", ">= 0")
  gem.add_development_dependency("simplecov", ">= 0")
  gem.add_development_dependency("yard", ">= 0")
  gem.add_development_dependency("redcarpet", ">= 0")
end
