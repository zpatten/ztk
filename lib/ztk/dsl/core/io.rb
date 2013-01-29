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

module ZTK::DSL::Core

  # @author Zachary Patten <zachary@jovelabs.net>
  # @api private
  module IO

    def self.included(base)
      base.class_eval do
        base.send(:extend, ZTK::DSL::Core::IO::ClassMethods)
      end
    end

    # @author Zachary Patten <zachary@jovelabs.net>
    module ClassMethods

      def load(rb_file)
        new do
          instance_eval(::IO.read(rb_file))
        end
      end

    end

  end
end
