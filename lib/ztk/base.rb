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

require "ostruct"

module ZTK

  # ZTK::Base Error Class
  class BaseError < Error; end

  # ZTK Base Class
  #
  # This is the base class inherited by most of the other classes in this
  # library.  It provides a standard set of features to control STDOUT, STDERR
  # and STDIN, a configuration mechanism and logging mechanism.
  #
  # You should never interact with this class directly; you should inherit it
  # and extend functionality as appropriate.
  class Base

    # @param [Hash] config Configuration options hash.
    # @option config [IO] :stdout Instance of IO to be used for STDOUT.
    # @option config [IO] :stderr Instance of IO to be used for STDERR.
    # @option config [IO] :stdin Instance of IO to be used for STDIN.
    # @option config [Logger] :logger Instance of Logger to be used for logging.
    def initialize(config={})
      # defined?(Rails) and rails_logger = Rails.logger
      @config = OpenStruct.new({
        :stdout => $stdout,
        :stderr => $stderr,
        :stdin => $stdin,
        :logger => ($logger || ZTK::Logger.new("/dev/null"))
      }.merge(config))

      (@config.stdout && @config.stdout.respond_to?(:sync=)) and @config.stdout.sync = true
      (@config.stderr && @config.stderr.respond_to?(:sync=)) and @config.stderr.sync = true
      (@config.stdin  && @config.stdin.respond_to?(:sync=))  and @config.stdin.sync = true
      (@config.logger && @config.logger.respond_to?(:sync=)) and @config.logger.sync = true

      @config.logger.debug { "config(#{@config.inspect})" }
    end

    # Configuration OpenStruct accessor method.
    #
    # If no block is given, the method will return the configuration OpenStruct
    # object.  If a block is given, the block is yielded with the configuration
    # OpenStruct object.
    #
    # @yieldparam [OpenStruct] config The configuration OpenStruct object.
    # @return [OpenStruct] The configuration OpenStruct object.
    def config(&block)
      if block_given?
        block.call(@config)
      else
        @config
      end
    end

    # Direct logging method.
    #
    # This method provides direct writing of data to the current log device.
    # This is mainly used for pushing STDOUT and STDERR into the log file in
    # ZTK::SSH and ZTK::Command, but could easily be used by other classes.
    #
    # The value returned in the block is passed down to the logger specified in
    # the classes configuration.
    #
    # @param [Symbol] method_name This should be any one of [:debug, :info, :warn, :error, :fatal].
    # @yield No value is passed to the block.
    # @yieldreturn [String] The message to log.
    def direct_log(log_level, &blocK)
      @config.logger.nil? and raise BaseError, "You must supply a logger for direct logging support!"

      if !block_given?
        raise BaseError, "You must supply a block to the log method!"
      elsif (@config.logger.level <= ZTK::Logger.const_get(log_level.to_s.upcase))
        if @config.logger.respond_to?(:logdev)
          @config.logger.logdev.write(yield)
        else
          @config.logger.instance_variable_get(:@logdev).instance_variable_get(:@dev).write(yield)
        end
      end
    end

  end

end
