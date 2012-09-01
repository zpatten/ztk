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
      @config = OpenStruct.new({
        :stdout => $stdout,
        :stderr => $stderr,
        :stdin => $stdin,
        :logger => $logger
      }.merge(config))
      @config.stdout.sync = true if @config.stdout.respond_to?(:sync=)
      @config.stderr.sync = true if @config.stderr.respond_to?(:sync=)
      @config.stdin.sync = true if @config.stdin.respond_to?(:sync=)
      @config.logger.sync = true if @config.logger.respond_to?(:sync=)
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

  end

################################################################################

end

################################################################################
