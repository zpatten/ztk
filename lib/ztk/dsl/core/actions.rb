module ZTK::DSL::Core

  # @author Zachary Patten <zpatten AT jovelabs DOT io>
  # @api private
  module Actions
    require 'ztk/dsl/core/actions/find'
    require 'ztk/dsl/core/actions/timestamps'

    def self.included(base)
      base.class_eval do
        base.send(:include, ZTK::DSL::Core::Actions::Find)
        base.send(:include, ZTK::DSL::Core::Actions::Timestamps)
      end
    end

  end
end
