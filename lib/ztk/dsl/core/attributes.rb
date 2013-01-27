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
  module Attributes

    def self.included(base)
      base.class_eval do
        base.send(:extend, ZTK::DSL::Core::Attributes::ClassMethods)
      end
    end

    def attributes
      @attributes ||= {}
    end

    module ClassMethods
      def attribute(key, options={})
        send(:define_method, key) do |*args|
          if args.count == 0
            attributes[key]
          else
            send("#{key}=", *args)
          end
        end

        send(:define_method, "#{key}=") do |value|
          attributes[key] = value
        end
      end
    end

  end
end
