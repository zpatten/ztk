################################################################################
#
#      Author: Zachary Patten <zachary@jovelabs.com>
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

################################################################################

module ZTK

################################################################################

  class BaseError < Error; end

################################################################################

  class Base

    # @param [Hash] config configuration options hash
    # @option config [IO] :stdout instance of IO to be used for STDOUT
    # @option config [IO] :stderr instance of IO to be used for STDERR
    # @option config [IO] :stdin instance of IO to be used for STDIN
    # @option config [Logger] :logger instance of Logger to be used for logging
    def initialize(config={})
      defined?(Rails) and rails_logger = Rails.logger
      @config = OpenStruct.new({
        :stdout => $stdout,
        :stderr => $stderr,
        :stdin => $stdin,
        :logger => (rails_logger || $logger)
      }.merge(config))

      @config.stdout.respond_to?(:sync=) and @config.stdout.sync = true
      @config.stderr.respond_to?(:sync=) and @config.stderr.sync = true
      @config.stdin.respond_to?(:sync=) and @config.stdin.sync = true
      @config.logger.respond_to?(:sync=) and @config.logger.sync = true

      log(:debug) { "config(#{@config.inspect})" }
    end

    #
    # If no block is given, the method will return the configuration OpenStruct
    # object.  If a block is given, the block is yielded with the configuration
    # OpenStruct object.
    #
    # @yieldparam [OpenStruct] config the configuration OpenStruct
    # @return [OpenStruct] the configuration OpenStruct
    def config(&block)
      if block_given?
        block.call(@config)
      else
        @config
      end
    end

################################################################################

    #
    def log(method_name, &block)
      if block_given?
        @config.logger and @config.logger.method(method_name.to_sym).call { yield }
      else
        raise(Error, "You must supply a block to the log method!")
      end
    end

################################################################################

  end

################################################################################

end

################################################################################
