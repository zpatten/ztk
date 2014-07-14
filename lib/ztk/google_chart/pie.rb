module ZTK
  module GoogleChart

    # GoogleChart Pie Chart
    class Pie < ZTK::GoogleChart::Base

      def initialize(configuration={})
        super({ :type => 'PieChart' }.merge(configuration))
      end

    end

  end
end
