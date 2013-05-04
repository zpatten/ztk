module ZTK::DSL::Core::Actions

  # @author Zachary Patten <zachary AT jovelabs DOT com>
  # @api private
  module Timestamps

    def self.included(base)
      base.class_eval do
        base.send(:extend, ZTK::DSL::Core::Actions::Timestamps::ClassMethods)
      end
      base.instance_eval do
        attribute :created_at
        attribute :updated_at
      end
    end

    # @author Zachary Patten <zachary AT jovelabs DOT com>
    module ClassMethods

      def updated_at_timestamp
        self.updated_at = Time.now
      end

      def created_at_timestamp
        self.created_at ||= Time.now
      end

    end

  end
end
