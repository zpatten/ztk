module ZTK
  module GoogleChart
    class Base

      module ArrayToDataTable

        def array_to_data_table(data)
          @chart_method = :array_to_data_table
          @chart_data = data

          config.ui.logger.info { "array_to_data_table(#{data.inspect})" }

          @chart_data
        end

        def array_to_data_table_function
          <<-EOCHART
  function #{@chart_draw_tag}() {

    #{@chart_data_tag} = new google.visualization.arrayToDataTable(
      #{@chart_data.to_json}
    );

    var #{@chart_options_tag} = #{JSON.pretty_generate(@chart_options)};

    #{@chart_name_tag} = new google.visualization.#{@chart_type_tag}(document.getElementById('#{@chart_div_tag}'));
    #{@chart_name_tag}.draw(#{@chart_data_tag}, #{@chart_options_tag});
  }
EOCHART
        end

        def array_to_data_table_render
          body do
            array_to_data_table_function
          end
        end

      end

    end
  end
end
