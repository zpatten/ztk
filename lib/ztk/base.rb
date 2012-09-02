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

################################################################################

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

################################################################################

    def config(&block)
      if block_given?
        block.call(@config)
      else
        @config
      end
    end

################################################################################

    def log(method_name, &block)
      if block_given?
        @config.logger and @config.logger.method(method_name.to_sym).call{ yield }
      else
        raise Error, "You must supply a block to the log method!"
      end
    end

################################################################################

  end

################################################################################

end

################################################################################
