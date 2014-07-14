module ZTK

  # GoogleChart Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  module GoogleChart

    # GoogleChart Error Class
    #
    # @author Zachary Patten <zachary AT jovelabs DOT com>
    class GoogleChartError < Error; end

    require 'ztk/google_chart/base'

    require 'ztk/google_chart/annotation'
    require 'ztk/google_chart/bar'
    require 'ztk/google_chart/candlestick'
    require 'ztk/google_chart/column'
    require 'ztk/google_chart/combo'
    require 'ztk/google_chart/line'
    require 'ztk/google_chart/pie'
    require 'ztk/google_chart/sankey'

  end

end
