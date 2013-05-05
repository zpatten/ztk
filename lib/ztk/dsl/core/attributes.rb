module ZTK::DSL::Core

  # @author Zachary Patten <zachary AT jovelabs DOT com>
  # @api private
  module Attributes

    def self.included(base)
      base.class_eval do
        base.send(:extend, ZTK::DSL::Core::Attributes::ClassMethods)
      end
    end

    def attributes
      @attributes ||= {}
    end

    # @author Zachary Patten <zachary AT jovelabs DOT com>
    module ClassMethods

      def attribute(key, options={})
        @attributes ||= {}
        @attributes[key] = options[:default]

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
