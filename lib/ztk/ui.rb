require 'base64'

module ZTK

  # ZTK::UI Error Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class UIError < Error; end

  # ZTK UI Class
  #
  # This class encapsulates a STDOUT, STDERR, STDIN
  # and logging device.
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class UI < ZTK::Base

    attr_accessor :stdout, :stderr, :stdin, :logger

    def initialize(configuration={})
      defined?(Rails) and (rails_logger = Rails.logger)
      null_logger = (::ZTK::Logger.new("/dev/null") rescue ::Logger.new("/dev/null"))

      @stdout = (configuration[:stdout] || $stdout || STDOUT)
      @stderr = (configuration[:stderr] || $stderr || STDERR)
      @stdin  = (configuration[:stdin]  || $stdin  || STDIN)
      @logger = (configuration[:logger] || $logger || rails_logger || null_logger)

      (@stdout && @stdout.respond_to?(:sync=)) and @stdout.sync = true
      (@stderr && @stderr.respond_to?(:sync=)) and @stderr.sync = true
      (@stdin  && @stdin.respond_to?(:sync=))  and @stdin.sync  = true
      (@logger && @logger.respond_to?(:sync=)) and @logger.sync = true
    end

  end

end
