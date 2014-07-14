module ZTK
  module GoogleChart

    # GoogleChart Sankey Chart
    class Sankey < ZTK::GoogleChart::Base

      def initialize(configuration={})
        super({ :type => 'Sankey' }.merge(configuration))
      end

    end

  end
end
