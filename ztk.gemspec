################################################################################
#
#      Author: Zachary Patten <zachary AT jovelabs DOT com>
#   Copyright: Copyright (c) Zachary Patten
#     License: Apache License, Version 2.0
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
################################################################################
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ztk/version'

Gem::Specification.new do |spec|
  spec.name          = "ztk"
  spec.version       = ZTK::VERSION
  spec.authors       = ["Zachary Patten"]
  spec.email         = ["zachary AT jovelabs DOT com"]
  spec.description   = <<-EOTEXT
Zachary's Tool Kit is a general purpose utility gem, featuring a collection of classes meant to simplify development of complex systems in Ruby.

ZTK::Background
===============
Easily turn most iterative tasks into a parallel processes and easily leverage multiple cores to speed up processing large sets of data.

ZTK::DSL
========
Create your own DSL in seconds by inheriting this DSL class.  Featuring ActiveRecord style associations where DSL objects can `belong_to` or `has_many` other DSL objects.

ZTK::Logger
===========
Based off the core Ruby logger, this is meant to be a drop in replacement.  Features added logging information, including PID, uSec time resolution, method and line numbers of logging statements (i.e. the caller).  One can seamlessly chain Ruby loggers using ZTK:Logger, for example to output logs to both STDOUT and a log file on disk at the same time; all while maintaining compatibility with the core Ruby logger.

ZTK::SSH
========
An SSH class that nicely wraps up all of the SSH gems into a nice uniform interface, complete with transfer progress callbacks.  It is meant to function as a drop in replacement, but I admit this has not been heavily tested like in the case of the ZTK::Logger class.  It provides the ability to switch between SCP and SFTP for file transfers seamlessly.  Full SSH proxy support as well, plus methods to spawn up interactive SSH consoles via `Kernel.exec`.
EOTEXT
  spec.summary       = %q{Zachary's Tool Kit}
  spec.homepage      = "https://github.com/zpatten/ztk"
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files`.split($\)
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency("activesupport")
  spec.add_dependency("erubis")
  spec.add_dependency("net-ssh")
  spec.add_dependency("net-ssh-gateway")
  spec.add_dependency("net-sftp")
  spec.add_dependency("net-scp")

  spec.add_development_dependency("pry")
  spec.add_development_dependency("rake")
  spec.add_development_dependency("rspec")
  spec.add_development_dependency("yard")
  spec.add_development_dependency("redcarpet")
  spec.add_development_dependency("coveralls")
  spec.add_development_dependency("travis")
end
