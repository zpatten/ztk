module ZTK
  module GoogleChart
    class Base

      module Options

        def options=(value)
          set_options(value)
        end

        def options(value=nil)
          set_options(value)
        end

      private

        def default_width
          900
        end

        def set_options(value=nil)
          if @chart_options.nil?
            @chart_options = Hash.new
            @chart_options.merge!(:width => default_width.to_i, :height => default_width.div(2).to_i)
          end

          if !value.nil? && !value.empty?
            @chart_options.merge!(value)
          end

          config.ui.logger.info { "options(#{value.inspect}) -> #{@chart_options.inspect}" }

          @chart_options
        end

      end

    end
  end
end
