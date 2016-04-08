################################################################################
#
#      Author: Zachary Patten <zpatten AT jovelabs DOT io>
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

require 'codeclimate-test-reporter'
require 'coveralls'
require 'simplecov'
require 'simplecov-rcov'
require 'yarjuf'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [
    CodeClimate::TestReporter::Formatter,
    Coveralls::SimpleCov::Formatter,
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::RcovFormatter
  ]
)

SimpleCov.start

################################################################################

require 'tempfile'
require 'ztk'

ENV['LOG_LEVEL'] = "DEBUG"

WAIT_SMALL = 5
READ_PARTIAL_CHUNK = 2048

################################################################################
