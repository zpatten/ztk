require 'active_support/inflector'

module ZTK

  # Generic Domain-specific Language Interface
  #
  # @see ZTK::DSL::Base
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  module DSL

    # @author Zachary Patten <zachary AT jovelabs DOT com>
    class DSLError < Error; end

    require 'ztk/dsl/core'
    require 'ztk/dsl/base'

  end
end
