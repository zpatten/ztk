module ZTK
  module GoogleChart
    class Base

      module DataTable

        def data_table(function, *args)
          @chart_method = :data_table
          @chart_data_table ||= Array.new

          @chart_data_table << [function, *args]
        end

        def data_table_function(&block)
          <<-EOCHART
  function #{@chart_draw_tag}() {

    #{@chart_data_tag} = new google.visualization.DataTable();
#{block.call.chomp}

    var #{@chart_options_tag} = #{JSON.pretty_generate(@chart_options).__fix_date};

    #{@chart_name_tag} = new google.visualization.#{@chart_type_tag}(document.getElementById('#{@chart_div_tag}'));
    #{@chart_name_tag}.draw(#{@chart_data_tag}, #{@chart_options_tag});
  }
EOCHART
        end

        def data_table_render
          data_table_blob = Array.new
          @chart_data_table.each do |function, *args|
            args = args.collect do |arg|
              if arg.is_a?(Array)
                JSON.pretty_generate(arg).__fix_date
              else
                arg.to_json
              end
            end.join(', ')
            data_table_blob << %(    #{@chart_data_tag}.#{function}(#{args});)
          end

          body do
            data_table_function do
              data_table_blob.join("\n")
            end
          end
        end

      end

    end
  end
end
