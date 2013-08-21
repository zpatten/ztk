module ZTK::DSL::Core

  # @author Zachary Patten <zachary AT jovelabs DOT com>
  # @api private
  module Attributes

    def self.included(base)
      base.class_eval do
        base.send(:extend, ZTK::DSL::Core::Options::ClassMethods)
        base.add_option(:attribute)
        base.send(:extend, ZTK::DSL::Core::Attributes::ClassMethods)
      end
    end

    def attributes
      @attributes ||= Hash.new
    end

    # @author Zachary Patten <zachary AT jovelabs DOT com>
    module ClassMethods

      def attribute(key, options={})
        attribute_options[key] = options

        send(:define_method, key) do |*args|
          if (attributes[key].nil? && !self.class.attribute_options[key][:default].nil?)
            default_value = (self.class.attribute_options[key][:default].dup rescue self.class.attribute_options[key][:default])

            attributes[key] ||= default_value
          end

          if args.count == 0
            attributes[key]
          else
            send("#{key}=", *args)
          end
        end

        send(:define_method, "#{key}=") do |value|
          attributes[key] = value
          value
        end

        self.class.send(:define_method, "find_by_#{key}") do |value|
          all.select{ |object| (object.send(key) == value) }
        end

      end

    end

  end
end
