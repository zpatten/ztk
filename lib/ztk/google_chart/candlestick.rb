module ZTK
  module GoogleChart

    # GoogleChart Candlestick Chart
    class Candlestick < ZTK::GoogleChart::Base

      def initialize(configuration={})
        super({ :type => 'CandlestickChart' }.merge(configuration))
      end

    end

  end
end
