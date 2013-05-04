################################################################################
#
#      Author: Zachary Patten <zachary AT jovelabs DOT com>
#   Copyright: Copyright (c) Zachary Patten
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
require "logger"

module ZTK

  # Standard Logging Class
  #
  # Supplies loggers the same as the base ruby logger class, except adds some
  # extra spice to your log messages.  This includes uSec timestamping, PIDs and
  # caller tree details.
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
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Logger < ::Logger

    # Log Levels
    SEVERITIES = Severity.constants.inject([]) {|arr,c| arr[Severity.const_get(c)] = c; arr}

    def initialize(*args)
      super(*args)
      set_log_level
    end

    # Provides access to the raw log device.
    def logdev
      self.instance_variable_get(:@logdev).instance_variable_get(:@dev)
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

    # Generates a human-readable string about the logger.
    def inspect
      "#<#{self.class} filename=#{@logdev.filename.inspect}>"
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

      message = [message, progname].flatten.compact.join(": ")
      message = "%19s.%06d|%05d|%5s|%s%s\n" % [Time.now.utc.strftime("%Y-%m-%d|%H:%M:%S"), Time.now.utc.usec, Process.pid, SEVERITIES[severity], called_by, message]

      @logdev.write(message)
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
