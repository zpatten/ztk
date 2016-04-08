module ZTK::DSL::Core

  # @author Zachary Patten <zpatten AT jovelabs DOT io>
  # @api private
  module Options

    def self.included(base)
      base.class_eval do
        base.send(:extend, ZTK::DSL::Core::Options::ClassMethods)
      end
    end

    # @author Zachary Patten <zpatten AT jovelabs DOT io>
    module ClassMethods

      def add_option(key)
        option_key = "#{key}_options"
        cattr_accessor option_key
        send(option_key) || send("#{option_key}=", {})
      end

    end

  end
end
