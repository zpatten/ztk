module ZTK
  module GoogleChart

    # GoogleChart Line Chart
    class Line < ZTK::GoogleChart::Base

      def initialize(configuration={})
        super({ :type => 'LineChart' }.merge(configuration))
      end

    end

  end
end
