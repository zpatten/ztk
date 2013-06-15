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
  spec.description   = %q{Zachary's (DevOp) Tool Kit}
  spec.summary       = %q{Zachary's (DevOp) Tool Kit}
  spec.homepage      = "https://github.com/zpatten/ztk"
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files`.split($\)
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency("activesupport")
  spec.add_dependency("childprocess", "0.3.6")
  spec.add_dependency("erubis")
  spec.add_dependency("net-ssh")
  spec.add_dependency("net-sftp")
  spec.add_dependency("os")

  spec.add_development_dependency("pry")
  spec.add_development_dependency("rake")
  spec.add_development_dependency("rspec")
  spec.add_development_dependency("yard")
  spec.add_development_dependency("redcarpet")
  spec.add_development_dependency("coveralls")
end
