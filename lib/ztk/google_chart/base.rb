class String
  def __fix_date
    self.gsub(/"new/, 'new').gsub(/\)"/, ')')
  end
end

module ZTK
  module GoogleChart

    # GoogleChart Base Class
    class Base < ZTK::Base
      require 'ztk/google_chart/base/array_to_data_table'
      require 'ztk/google_chart/base/data_table'
      require 'ztk/google_chart/base/dates'
      require 'ztk/google_chart/base/options'
      require 'ztk/google_chart/base/ticks'

      include ZTK::GoogleChart::Base::ArrayToDataTable
      include ZTK::GoogleChart::Base::DataTable
      include ZTK::GoogleChart::Base::Dates
      include ZTK::GoogleChart::Base::Options
      include ZTK::GoogleChart::Base::Ticks

      # @param [Hash] configuration Configuration options hash.
      def initialize(configuration={})
        super({ :id => generate_id }, configuration)

        @id = config.id.to_s.underscore.gsub(/ /, '')
        @chart_name_tag = "chart_#{@id}"
        @chart_data_tag = "#{@chart_name_tag}_data"
        @chart_options_tag = "#{@chart_name_tag}_options"
        @chart_draw_tag = "#{@chart_name_tag}_draw"
        @chart_div_tag = "#{@chart_name_tag}_div"
        @chart_type_tag = config.type
      end

      def render(content=nil)
        case @chart_method
        when :data_table
          data_table_render
        when :array_to_data_table
          array_to_data_table_render
        else
          raise "You must supply chart data via DataTable or ArrayToDataTable!"
        end
      end

      def body(&block)
        <<-EOCHART
<script type="text/javascript" src="https://www.google.com/jsapi"></script>
<script type="text/javascript">
  var #{@chart_data_tag};
  var #{@chart_name_tag};

  google.load('visualization', '1', {'packages':['corechart']});
  google.load('visualization', '1.1', {'packages':['annotationchart']});
  google.load('visualization', '1.1', {'packages':['sankey']});
  google.setOnLoadCallback(#{@chart_draw_tag});

#{block.call.chomp}
</script>
<div id="#{@chart_div_tag}"></div>
EOCHART
      end

      def generate_id
        generated_id = Array.new

        generated_id << SecureRandom.hex(16)

        generated_id.join('_')
      end

    end

  end
end
