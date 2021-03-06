module ZTK::DSL::Core

  # @author Zachary Patten <zpatten AT jovelabs DOT io>
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

    # @author Zachary Patten <zpatten AT jovelabs DOT io>
    module ClassMethods

      def attribute(key, options={})
        klass = self.to_s.split('::').last.downcase
        option_key = "#{klass}_#{key}"
        attribute_options[option_key] = options

        send(:define_method, key) do |*args|
          if (attributes[key].nil? && !self.class.attribute_options[option_key][:default].nil?)
            default_value = (self.class.attribute_options[option_key][:default].dup rescue self.class.attribute_options[option_key][:default])

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
