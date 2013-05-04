require 'active_support/inflector'

module ZTK

  # Generic Domain-specific Language Interface
  #
  # @see ZTK::DSL::Base
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  module DSL

    # @author Zachary Patten <zachary AT jovelabs DOT com>
    class DSLError < Error; end

    autoload :Base, "ztk/dsl/base"
    autoload :Core, "ztk/dsl/core"

  end
end
