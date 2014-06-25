module ZTK
  class Report

    # Report Spreadsheet Functionality
    module Spreadsheet

      # Displays data in a spreadsheet style.
      #
      #     +-------------+-------+-------+--------+----------------+-------------------+--------------+---------+
      #     | NAME        | ALIVE | ARCH  | DISTRO | IP             | MAC               | CHEF VERSION | PERSIST |
      #     +-------------+-------+-------+--------+----------------+-------------------+--------------+---------+
      #     | sudo        | false | amd64 | ubuntu | 192.168.99.110 | 00:00:5e:34:d6:aa | N/A          | true    |
      #     | timezone    | false | amd64 | ubuntu | 192.168.122.47 | 00:00:5e:92:d7:f6 | N/A          | true    |
      #     | chef-client | false | amd64 | ubuntu | 192.168.159.98 | 00:00:5e:c7:ce:26 | N/A          | true    |
      #     | users       | false | amd64 | ubuntu | 192.168.7.78   | 00:00:5e:89:f9:50 | N/A          | true    |
      #     +-------------+-------+-------+--------+----------------+-------------------+--------------+---------+
      #
      # @param [Array<Object>,Object] dataset A single object or an array of
      #   objects for which we want to generate a report
      # @param [Array] headers An array of headers used for ordering the output.
      # @return [OpenStruct]
      def spreadsheet(dataset, headers, &block)
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
          max_lengths = max_spreadsheet_lengths(headers, rows)
          header_line = headers.collect { |header| "%-#{max_lengths.send(:table)[header]}s" % header.to_s.upcase }
          header_line = format_row(header_line)

          config.ui.stdout.puts(format_header(headers, max_lengths))
          config.ui.stdout.puts(header_line)
          config.ui.stdout.puts(format_header(headers, max_lengths))

          rows.each do |row|
            row_line = headers.collect do |header|
              header_length = max_lengths.send(:table)[header]
              content = (row.send(:table) rescue row)[header]

              "%-#{header_length}s" % content
            end

            row_line = format_row(row_line)
            config.ui.stdout.puts(row_line)
          end

          config.ui.stdout.puts(format_header(headers, max_lengths))
          OpenStruct.new(:rows => rows, :max_lengths => max_lengths, :width => calculate_spreadsheet_width(headers, max_lengths))
        else
          OpenStruct.new(:rows => rows, :max_lengths => 0, :width => 0)
        end

      end

    end

  end
end
