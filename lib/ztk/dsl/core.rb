module ZTK::DSL

  # DSL Core
  #
  # @author Zachary Patten <zpatten AT jovelabs DOT io>
  # @api private
  module Core
    require 'ztk/dsl/core/attributes'
    require 'ztk/dsl/core/actions'
    require 'ztk/dsl/core/dataset'
    require 'ztk/dsl/core/io'
    require 'ztk/dsl/core/options'
    require 'ztk/dsl/core/relations'

    def self.included(base)
      base.class_eval do
        base.send(:extend, ZTK::DSL::Core::ClassMethods)

        # base.send(:extend, ZTK::DSL::Core::DualMethods)
        # base.send(:include, ZTK::DSL::Core::DualMethods)

        base.send(:include, ZTK::DSL::Core::Attributes)
        base.send(:include, ZTK::DSL::Core::Actions)
        base.send(:include, ZTK::DSL::Core::Dataset)
        base.send(:include, ZTK::DSL::Core::IO)
        base.send(:include, ZTK::DSL::Core::Options)
        base.send(:include, ZTK::DSL::Core::Relations)
      end
    end

    # @author Zachary Patten <zpatten AT jovelabs DOT io>
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

    # @author Zachary Patten <zpatten AT jovelabs DOT io>
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
