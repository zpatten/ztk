################################################################################
#
#      Author: Zachary Patten <zachary@jovelabs.net>
#   Copyright: Copyright (c) Jove Labs
#     License: Apache License, Version 2.0
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
################################################################################

require 'socket'
require 'timeout'

module ZTK

  # ZTK::Report Error Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class ReportError < Error; end

  # @author Zachary Patten <zachary@jovelabs.net>
  class Report < ZTK::Base

    # @param [Hash] configuration Configuration options hash.
    def initialize(configuration={})
      super({
      }.merge(configuration))
      config.logger.debug { "config=#{config.send(:table).inspect}" }
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

    def spreadsheet(dataset, headers, &block)
      !block_given? and log_and_raise(ReportError, "You must supply a block!")
      headers.nil? and log_and_raise(ReportError, "Headers can not be nil!")
      dataset.nil? and log_and_raise(ReportError, "Dataset can not be nil!")

      rows = Array.new
      max_lengths = OpenStruct.new
      headers = headers.map(&:downcase).map(&:to_sym)

      dataset.each do |data|
        rows << block.call(data)
      end

      headers.each do |header|
        maximum = [header, rows.collect{ |r| r.send(header) }].flatten.map(&:to_s).map(&:length).max
        max_lengths.send("#{header}=", maximum)
      end

      header_line = headers.collect do |header|
        "%-#{max_lengths.send(header)}s" % header.to_s.upcase
      end
      header_line = format_row(header_line)

      config.stdout.puts(format_header(headers, max_lengths))
      config.stdout.puts(header_line)
      config.stdout.puts(format_header(headers, max_lengths))

      rows.each do |row|
        row_line = headers.collect do |header|
          "%-#{max_lengths.send(header)}s" % row.send(header)
        end
        row_line = format_row(row_line)
        config.stdout.puts(row_line)
      end

      config.stdout.puts(format_header(headers, max_lengths))

      OpenStruct.new(:rows => rows, :max_lengths => max_lengths, :width => (2 + max_lengths.send(:table).values.reduce(:+) + ((headers.count * 3) - 3) + 2))
    end

    def list
    end

  end

end
