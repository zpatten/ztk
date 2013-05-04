module ZTK::DSL::Core

  # @author Zachary Patten <zachary AT jovelabs DOT com>
  # @api private
  module Actions
    autoload :Find, "ztk/dsl/core/actions/find"
    autoload :Timestamps, "ztk/dsl/core/actions/timestamps"

    def self.included(base)
      base.class_eval do
        base.send(:include, ZTK::DSL::Core::Actions::Find)
        base.send(:include, ZTK::DSL::Core::Actions::Timestamps)
      end
    end

  end
end
