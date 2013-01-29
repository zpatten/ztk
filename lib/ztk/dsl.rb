################################################################################
#
#      Author: Zachary Patten <zachary@jovelabs.net>
#   Copyright: Copyright (c) Jove Labs
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
require "active_support/inflector"

module ZTK

  # Generic Domain-specific Language Interface
  #
  # @see ZTK::DSL::Base
  # @author Zachary Patten <zachary@jovelabs.net>
  module DSL

    # @author Zachary Patten <zachary@jovelabs.net>
    class DSLError < Error; end

    autoload :Base, "ztk/dsl/base"
    autoload :Core, "ztk/dsl/core"

  end
end
