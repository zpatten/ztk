module ZTK::DSL::Core

  # @author Zachary Patten <zachary AT jovelabs DOT com>
  # @api private
  module Dataset

    def self.included(base)
      base.class_eval do
        base.send(:extend, ZTK::DSL::Core::Dataset::ClassMethods)
      end
    end

    # @author Zachary Patten <zachary AT jovelabs DOT com>
    module ClassMethods
      @@id ||= 0

      def dataset
        klass = self.to_s.underscore.to_sym
        @@dataset ||= {}
        if @@dataset.key?(klass)
          @@dataset[klass]
        else
          @@dataset[klass] ||= []
        end
      end

      def purge
        @@dataset = nil
      end

      def id
        @@id
      end

      def next_id
        @@id += 1
        @@id
      end

    end

  end
end
