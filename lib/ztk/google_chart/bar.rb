module ZTK
  module GoogleChart

    # GoogleChart Bar Chart
    class Bar < ZTK::GoogleChart::Base

      def initialize(configuration={})
        super({ :type => 'BarChart' }.merge(configuration))
      end

    end

  end
end
