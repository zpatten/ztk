module ZTK
  module GoogleChart

    # GoogleChart Combo Chart
    class Combo < ZTK::GoogleChart::Base

      def initialize(configuration={})
        super({ :type => 'ComboChart' }.merge(configuration))
      end

    end

  end
end
