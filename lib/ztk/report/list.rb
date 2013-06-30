module ZTK
  class Report

    # Report List Functionality
    module List

      # Displays data in a key-value list style.
      #
      #     +-------------------------------------------------------------------+
      #     |                      PROVIDER: Cucumber::Chef::Provider::Vagrant  |
      #     |                            ID: default                            |
      #     |                         STATE: aborted                            |
      #     |                      USERNAME: vagrant                            |
      #     |                    IP ADDRESS: 127.0.0.1                          |
      #     |                          PORT: 2222                               |
      #     |               CHEF-SERVER API: http://127.0.0.1:4000              |
      #     |             CHEF-SERVER WEBUI: http://127.0.0.1:4040              |
      #     |      CHEF-SERVER DEFAULT USER: admin                              |
      #     |  CHEF-SERVER DEFAULT PASSWORD: p@ssw0rd1                          |
      #     +-------------------------------------------------------------------+
      #
      # @param [Array<Object>,Object] dataset A single object or an array of
      #   objects for which we want to generate a report
      # @param [Array] headers An array of headers used for ordering the output.
      # @return [OpenStruct]
      def list(dataset, headers, &block)
        !block_given? and log_and_raise(ReportError, "You must supply a block!")
        headers.nil? and log_and_raise(ReportError, "Headers can not be nil!")
        dataset.nil? and log_and_raise(ReportError, "Dataset can not be nil!")

        rows = Array.new
        max_lengths = OpenStruct.new
        headers = headers.map(&:to_s).map(&:downcase).map(&:to_sym)

        if dataset.is_a?(Array)
          dataset.each do |data|
            rows << block.call(data)
          end
        else
          rows << block.call(dataset)
        end
        rows.compact!

        if rows.count > 0
          max_key_length = headers.collect{ |header| header.to_s.length }.max
          max_value_length = rows.collect{ |row| headers.collect{ |header| row.send(:table)[header].to_s.length }.max }.max

          width = (max_key_length + max_value_length + 2 + 2 + 2)

          rows.each do |row|
            config.ui.stdout.puts("+#{"-" * width}+")
            headers.each do |header|
              entry_line = format_entry(header, max_key_length, row.send(:table)[header], max_value_length)
              config.ui.stdout.puts(entry_line)
            end
          end
          config.ui.stdout.puts("+#{"-" * width}+")
          OpenStruct.new(:rows => rows, :max_key_length => max_key_length, :max_value_length => max_value_length, :width => width)
        else
          OpenStruct.new(:rows => rows, :max_key_length => 0, :max_value_length => 0, :width => 0)
        end
      end

    end

  end
end
