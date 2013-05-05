require 'socket'
require 'timeout'

module ZTK

  # Report Error Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class ReportError < Error; end

  # Report Class
  #
  # This class contains tools for generating spreadsheet or key-value list
  # styled output.  Report methods are currently meant to be interchangeable;
  # that is one should be able to just switch which method they are calling
  # to change the output type.
  #
  # The idea here is that everything is auto-sized and simply displayed.
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Report < ZTK::Base

    # @param [Hash] configuration Configuration options hash.
    def initialize(configuration={})
      super({
      }.merge(configuration))
      config.ui.logger.debug { "config=#{config.send(:table).inspect}" }
    end

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
      headers = headers.map(&:downcase).map(&:to_sym)

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
        header_line = headers.collect { |header| "%-#{max_lengths.send(header)}s" % header.to_s.upcase }
        header_line = format_row(header_line)

        config.ui.stdout.puts(format_header(headers, max_lengths))
        config.ui.stdout.puts(header_line)
        config.ui.stdout.puts(format_header(headers, max_lengths))

        rows.each do |row|
          row_line = headers.collect do |header|
            header_length = max_lengths.send(header)
            content = row.send(header)

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
      headers = headers.map(&:downcase).map(&:to_sym)

      if dataset.is_a?(Array)
        dataset.each do |data|
          rows << block.call(data)
        end
      else
        rows << block.call(dataset)
      end
      rows.compact!

      if rows.count > 0
        max_key_length = headers.collect{ |header| header.length }.max
        max_value_length = rows.collect{ |row| headers.collect{ |header| row.send(header).to_s.length }.max }.max

        width = (max_key_length + max_value_length + 2 + 2 + 2)

        rows.each do |row|
          config.ui.stdout.puts("+#{"-" * width}+")
          headers.each do |header|
            entry_line = format_entry(header, max_key_length, row.send(header), max_value_length)
            config.ui.stdout.puts(entry_line)
          end
        end
        config.ui.stdout.puts("+#{"-" * width}+")
        OpenStruct.new(:rows => rows, :max_key_length => max_key_length, :max_value_length => max_value_length, :width => width)
      else
        OpenStruct.new(:rows => rows, :max_key_length => 0, :max_value_length => 0, :width => 0)
      end
    end


  private

    def max_spreadsheet_lengths(headers, rows)
      max_lengths = OpenStruct.new
      headers.each do |header|
        collection = [header, rows.map(&header)].flatten
        maximum = collection.map(&:to_s).map(&:length).max
        max_lengths.send("#{header}=", maximum)
      end
      max_lengths
    end

    def calculate_spreadsheet_width(headers, max_lengths)
      header_lengths = ((headers.count * 3) - 3)
      max_length = max_lengths.send(:table).values.reduce(:+)
      (2 + max_length + header_lengths + 2)
    end

    def format_header(headers, lengths)
      line = headers.collect do |header|
        "-" * lengths.send(header)
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
