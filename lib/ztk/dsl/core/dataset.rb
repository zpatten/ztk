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

      def dataset
        klass = self.to_s.underscore.to_sym

        @@dataset        ||= {}
        @@dataset[klass] ||= []

        @@dataset[klass]
      end

      def purge
        klass = self.to_s.underscore.to_sym

        @@dataset        ||= {}
        @@dataset[klass]   = []

        @@id             ||= {}
        @@id[klass]        = 0

        true
      end

      def next_id
        klass = self.to_s.underscore.to_sym

        @@id        ||= {}
        @@id[klass] ||= 0

        @@id[klass] += 1

        @@id[klass]
      end

    end

  end
end
