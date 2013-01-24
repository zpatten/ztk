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
module ZTK

  # ZTK::RescueRetry Error Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class RescueRetryError < Error; end

  # RescueRetry Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class RescueRetry

    class << self

      def try(options={}, &block)
        !block_given? and raise RescueRetryError, "You must supply a block!"

        options = { :logger => $logger, :tries => 1, :on => Exception }.merge(options)

        logger = options[:logger]
        tries = options[:tries]
        on = options[:on]

        logger and logger.debug { "options(#{options.inspect})" }

        begin
          return block.call
        rescue on => e
          if ((tries -= 1) > 0)
            logger and logger.warn { "Caught #{e.inspect}, we will give it #{tries} more tr#{tries > 1 ? 'ies' : 'y'}." }
            retry
          else
            logger and logger.fatal { "Caught #{e.inspect}, sorry, we have to give up now." }
            raise e
          end
        end

      end

    end

  end

end
