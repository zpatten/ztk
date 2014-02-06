require 'logger'

module ZTK

  # Standard Logging Class
  #
  # Allows chaining standard Ruby loggers as well as adding extra spice to your
  # log messages.  This includes uSec timestamping, PIDs and caller tree
  # details.
  #
  # This class accepts the same initialize arguments as the Ruby logger class.
  # You can chain multiple loggers together, for example to get an effect of
  # logging to STDOUT and a file simultaneously without having to modify your
  # existing logging statements.
  #
  # One can override the logging level on the command line with programs that
  # use this library like so:
  #     LOG_LEVEL=DEBUG bin/cucumber-chef ssh
  #
  # = Typical usage:
  #
  #     $logger = ZTK::Logger.new("/dev/null")
  #
  #     $logger.debug { "This is a debug message!" }
  #     $logger.info { "This is a info message!" }
  #     $logger.warn { "This is a warn message!" }
  #     $logger.error { "This is a error message!" }
  #     $logger.fatal { "This is a fatal message!" }
  #
  # = Simple logger chain:
  #
  #     logger = ZTK::Logger.new
  #     logger.loggers << ::Logger.new(STDOUT)
  #     logger.loggers << ::Logger.new('test.log')
  #
  #     logger.debug { "This will be written to STDOUT as well as test.log!" }
  #
  # = Alternate logger chaining:
  #
  #     logger = ZTK::Logger.new(STDOUT)
  #     logger.loggers << ::Logger.new('test.log')
  #
  #     logger.debug { "This will be written to STDOUT as well as test.log!" }
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Logger < ::Logger

    # Log Levels
    SEVERITIES = Severity.constants.inject([]) {|arr,c| arr[Severity.const_get(c)] = c; arr}

    class LogDevice
      attr_reader   :dev
      attr_reader   :filename

      def initialize(chain)
        @chain    = chain
        @dev      = nil
        @filename = nil
      end

      def write(message)
        @chain.loggers.each do |logger|
          logger << message
        end
      end

      def close
        @chain.loggers.each do |logger|
          logger.instance_variable_get(:@logdev).close
        end
      end
    end


    attr_accessor :loggers

    def initialize(*args)
      super(::StringIO.new)

      @loggers = Array.new
      if args.count > 0
        @loggers << ::Logger.new(*args)
      end

      @logdev = LogDevice.new(self)

      set_log_level
    end

    # Generates a human-readable string about the logger.
    def inspect
      loggers_inspect = @loggers.collect{|logger| logger.instance_variable_get(:@logdev).instance_variable_get(:@dev).inspect }.join(', ')
      "#<#{self.class} loggers=[#{loggers_inspect}]>"
    end

    # Specialized logging.  Logs messages in the same format, except has the
    # option to shift the caller_at position to exposed the proper calling
    # method.
    #
    # Very useful in situations of class inheritence, for example, where you
    # might have logging statements in a base class, which are inherited by
    # another class.  When calling the base class method via the inherited class
    # the log messages will indicate the base class as the caller.  While this
    # is technically true it is not always what we want to see in the logs
    # because it is ambigious and does not show us where the call truly
    # originated from.
    def shift(severity, shift=0, &block)
      severity = ZTK::Logger.const_get(severity.to_s.upcase)
      add(severity, nil, nil, shift, &block)
    end

    def level=(value)
      @level = value

      @loggers.each { |logger| logger.level = @level }

      value
    end


  private

    # Parses caller entries, extracting the file, line number and method.
    #
    # @param [String] at Entry from the caller Array.
    def parse_caller(at)
      if /^(.+?):(\d+)(?::in `(.*)')?/ =~ at
        file = Regexp.last_match[1]
        line = Regexp.last_match[2]
        method = Regexp.last_match[3]
        "#{File.basename(file)}:#{line}:#{method}|"
      else
        ""
      end
    end

    # Writes a log message if the current log level is at or below the supplied
    # severity.
    #
    # @param [Constant] severity Log level severity.
    # @param [String] message Optional message to prefix the log entry with.
    # @param [String] progname Optional name of the program to prefix the log
    #   entry with.
    # @yieldreturn [String] The block should return the desired log message.
    def add(severity, message=nil, progname=nil, shift=0, &block)
      return if (@level > severity)

      message = block.call if message.nil? && block_given?
      return if message.nil?

      called_by = parse_caller(caller[1+shift])

      message = [message.chomp, progname].flatten.compact.join(": ")
      message = "%19s.%06d|%05d|%5s|%s%s\n" % [Time.now.utc.strftime("%Y-%m-%d|%H:%M:%S"), Time.now.utc.usec, Process.pid, SEVERITIES[severity], called_by, message]

      @logdev.write(ZTK::ANSI.uncolor(message))
      @logdev.respond_to?(:flush) and @logdev.flush

      true
    end

    # Sets the log level.
    #
    # @param [String] level Log level to use.
    def set_log_level(level=nil)
      defined?(Rails) and (default = (Rails.env.production? ? "INFO" : "DEBUG")) or (default = "INFO")
      log_level = (ENV['LOG_LEVEL'] || level || default)
      self.level = ZTK::Logger.const_get(log_level.to_s.upcase)
    end

  end

end
