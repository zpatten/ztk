module ZTK::DSL::Core

  # @author Zachary Patten <zpatten AT jovelabs DOT io>
  # @api private
  module Relations
    require 'ztk/dsl/core/relations/belongs_to'
    require 'ztk/dsl/core/relations/has_many'

    def self.included(base)
      base.class_eval do
        base.send(:extend, ZTK::DSL::Core::Relations::ClassMethods)
        base.send(:include, ZTK::DSL::Core::Relations::BelongsTo)
        base.send(:include, ZTK::DSL::Core::Relations::HasMany)
      end
    end

    # @author Zachary Patten <zpatten AT jovelabs DOT io>
    module ClassMethods

      def add_relation(key)
        relation_key = "#{key}_relations"
        cattr_accessor relation_key
        send(relation_key) || send("#{relation_key}=", {})
      end

    end

  end
end
