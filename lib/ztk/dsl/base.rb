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

# @author Zachary Patten <zachary@jovelabs.net>
module ZTK::DSL

  class Base
    include(ZTK::DSL::Core)
    include(ZTK::DSL::Core::Attributes)
    include(ZTK::DSL::Core::IO)
    include(ZTK::DSL::Core::Relations)

    def initialize(&block)
      block_given? and ((block.arity < 1) ? instance_eval(&block) : block.call(self))
    end

    def inspect
      details = Array.new
      details << "attributes=#{attributes.inspect}" if attributes.count > 0
      details << "relations=#{attributes.inspect}" if attributes.count > 0
      "#<ZTK::DSL #{details.join(', ')}>"
    end

  end

end
