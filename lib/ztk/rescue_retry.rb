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

  # ZTK RescueRetry Class
  #
  # This class contains an exception handling tool, which will allowing retry
  # of all or specific *Exceptions* based on a set number of attempts to make.
  #
  # The block is yielded and if a valid exception occurs the block will be
  # re-executed for the set number of attempts.
  #
  # For example, from the ZTK SSH class:
  #
  #     ZTK::RescueRetry.try(:tries => 3, :on => EOFError) do
  #       @ssh = Net::SSH.start(config.host_name, config.user, ssh_options)
  #       ...
  #     end
  #
  # If an SSH connection drops on the other side and we go to write to it, we
  # will get this error.  Wrapping the SSH code in *RescueRetry* allows us to
  # retry the connection in the event this happens.  If we have no luck after
  # 3 attempts at executing the block, *RescueRetry* surfaces the exception.
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class RescueRetry

    class << self

      # Rescue and Retry the supplied block.
      #
      # When no options are supplied, if an *Exception* is encounter it is
      # surfaced immediately and no retry is performed.
      #
      # It is advisable to at least leave the *delay* option at 1.  You could
      # optionally set this to 0, but this is generally a bad idea.
      #
      # @param [Hash] options Configuration options hash.
      # @option options [String] :tries (1) How many attempts at executing the
      #   block before we give up and surface the *Exception*.
      # @option options [String] :on (Exception) Watch for a specific exception
      #   instead of performing retry on all exceptions.
      # @option options [Float,Integer] :delay (1) How long to sleep for between
      #   each retry.
      #
      # @yield Block should execute the tasks to be rescued and retried if
      #   needed.
      # @return [Object] The return value of the block.
      def try(options={}, &block)
        options = Base.build_config({
          :tries => 1,
          :on => Exception,
          :delay => 1
        }.merge(options))
        options.logger.debug { "options=#{options.send(:table).inspect}" }

        !block_given? and Base.log_and_raise(options.logger, RescueRetryError, "You must supply a block!")

        begin
          return block.call
        rescue options.on => e
          if ((options.tries -= 1) > 0)
            options.logger.warn { "Caught #{e.inspect}, we will give it #{options.tries} more tr#{options.tries > 1 ? 'ies' : 'y'}." }
            sleep(options.delay)
            retry
          else
            options.logger.fatal { "Caught #{e.inspect} and we have no more tries left, sorry, we have to give up now." }
            raise e
          end
        end

      end

    end

  end

end
