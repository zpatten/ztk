module ZTK::DSL::Core

  # @author Zachary Patten <zpatten AT jovelabs DOT io>
  # @api private
  module IO

    def self.included(base)
      base.class_eval do
        base.send(:extend, ZTK::DSL::Core::IO::ClassMethods)
      end
    end

    # @author Zachary Patten <zpatten AT jovelabs DOT io>
    module ClassMethods

      def load(rb_file)
        new do
          instance_eval(::IO.read(rb_file), rb_file)
        end
      end

    end

  end
end
