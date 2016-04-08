module ZTK::DSL::Core::Actions

  # @author Zachary Patten <zpatten AT jovelabs DOT io>
  # @api private
  module Find

    def self.included(base)
      base.class_eval do
        base.send(:extend, ZTK::DSL::Core::Actions::Find::ClassMethods)
      end
    end

    # @author Zachary Patten <zpatten AT jovelabs DOT io>
    module ClassMethods

      def all
        dataset
      end

      def find(*args)
        ids = [args].flatten
        all.select{ |data| ids.include?(data.id) }
      end

      def first(*args)
        if args.count == 0
          all.first
        else
          find(*args).first
        end
      end

      def count
        all.count
      end

    end

  end
end
