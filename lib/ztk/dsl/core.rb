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

module ZTK::DSL

  # ZTK::DSL Core
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  # @api private
  module Core
    autoload :Attributes, "ztk/dsl/core/attributes"
    autoload :Actions, "ztk/dsl/core/actions"
    autoload :Dataset, "ztk/dsl/core/dataset"
    autoload :IO, "ztk/dsl/core/io"
    autoload :Relations, "ztk/dsl/core/relations"

    def self.included(base)
      base.class_eval do
        base.send(:extend, ZTK::DSL::Core::ClassMethods)

        # base.send(:extend, ZTK::DSL::Core::DualMethods)
        # base.send(:include, ZTK::DSL::Core::DualMethods)

        base.send(:include, ZTK::DSL::Core::Attributes)
        base.send(:include, ZTK::DSL::Core::Actions)
        base.send(:include, ZTK::DSL::Core::Dataset)
        base.send(:include, ZTK::DSL::Core::IO)
        base.send(:include, ZTK::DSL::Core::Relations)
      end
    end

    # @author Zachary Patten <zachary AT jovelabs DOT com>
    # module DualMethods

    #   def logger
    #     unless defined?($logger)
    #       $logger = ::ZTK::Logger.new("dsl.log")
    #       $logger.info {"=" * 80}
    #       $logger.info {"=" * 80}
    #       $logger.info {"=" * 80}
    #     end
    #     $logger
    #   end

    # end

    # @author Zachary Patten <zachary AT jovelabs DOT com>
    module ClassMethods

      def cattr_accessor(*args)
        cattr_reader(*args)
        cattr_writer(*args)
      end

      def cattr_reader(*args)
        args.flatten.each do |arg|
          next if arg.is_a?(Hash)
          instance_eval %Q{
            unless defined?(@@#{arg})
              @@#{arg} = nil
            end

            def #{arg}
              @@#{arg}
            end
          }
        end
      end

      def cattr_writer(*args)
        args.flatten.each do |arg|
          next if arg.is_a?(Hash)
          instance_eval %Q{
            unless defined?(@@#{arg})
              @@#{arg} = nil
            end

            def #{arg}=(value)
              @@#{arg} = value
            end
          }
        end
      end
    end

  end
end
