module ZTK
  module GoogleChart

    # GoogleChart Column Chart
    class Column < ZTK::GoogleChart::Base

      def initialize(configuration={})
        super({ :type => 'ColumnChart' }.merge(configuration))
      end

    end

  end
end
