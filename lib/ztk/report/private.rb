module ZTK
  class Report

    # Report Private Functionality
    module Private

      def max_spreadsheet_lengths(headers, rows)
        max_lengths = OpenStruct.new
        headers.each do |header|
          collection = [header, rows.collect{|r| (r.send(:table) rescue r)[header] } ].flatten
          maximum = collection.map(&:to_s).map(&:length).max
          (max_lengths.send(:table) rescue max_lengths)[header] = maximum
        end

        max_lengths
      end

      def calculate_spreadsheet_width(headers, max_lengths)
        header_lengths = ((headers.count * 3) - 3)
        max_length = (max_lengths.send(:table) rescue max_lengths).values.reduce(:+)
        (2 + max_length + header_lengths + 2)
      end

      def format_header(headers, lengths)
        line = headers.collect do |header|
          "-" * (lengths.send(:table) rescue lengths)[header]
        end

        ["+-", line.join("-+-"), "-+"].join.strip
      end

      def format_row(*args)
        spacer = " "
        [spacer, args, spacer].flatten.join(" | ").strip
      end

      def format_entry(key, key_length, value, value_length)
        "|  %#{key_length}s: %-#{value_length}s  |" % [key.to_s.upcase, value.to_s]
      end

    end

  end
end
