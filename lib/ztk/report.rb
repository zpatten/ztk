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
    require 'socket'
    require 'timeout'

    # @param [Hash] configuration Configuration options hash.
    def initialize(configuration={})
      super({
      }.merge(configuration))

      config.ui.logger.debug { "config=#{config.send(:table).inspect}" }
    end

    require 'ztk/report/list'
    require 'ztk/report/private'
    require 'ztk/report/spreadsheet'

    include ZTK::Report::List
    include ZTK::Report::Spreadsheet

  private

    include ZTK::Report::Private

  end

end
