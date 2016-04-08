require 'active_support/inflector'

module ZTK

  # Generic Domain-specific Language Interface
  #
  # @see ZTK::DSL::Base
  # @author Zachary Patten <zpatten AT jovelabs DOT io>
  module DSL

    # @author Zachary Patten <zpatten AT jovelabs DOT io>
    class DSLError < Error; end

    require 'ztk/dsl/core'
    require 'ztk/dsl/base'

  end
end
