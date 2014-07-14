module ZTK
  module GoogleChart

    # GoogleChart Annotation Chart
    class Annotation < ZTK::GoogleChart::Base

      def initialize(configuration={})
        super({ :type => 'AnnotationChart' }.merge(configuration))
      end

    end

  end
end
