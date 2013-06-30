module ZTK::DSL::Core

  # @author Zachary Patten <zachary AT jovelabs DOT com>
  # @api private
  module IO

    def self.included(base)
      base.class_eval do
        base.send(:extend, ZTK::DSL::Core::IO::ClassMethods)
      end
    end

    # @author Zachary Patten <zachary AT jovelabs DOT com>
    module ClassMethods

      def load(rb_file)
        new do
          instance_eval(::IO.read(rb_file), rb_file)
        end
      end

    end

  end
end
