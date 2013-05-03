################################################################################
#
#      Author: Zachary Patten <zachary@jovelabs.net>
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
  # *example code*:
  #
  #     counter = 0
  #     ZTK::RescueRetry.try(:tries => 3, :on => EOFError) do
  #       counter += 1
  #       raise EOFError
  #     end
  #     puts counter.inspect
  #
  #     counter = 0
  #     ZTK::RescueRetry.try(:tries => 3) do
  #       counter += 1
  #       raise "OMGWTFBBQ"
  #     end
  #     puts counter.inspect
  #
  #     counter = 0
  #     ZTK::RescueRetry.try(:tries => 3, :on => EOFError) do
  #       counter += 1
  #       raise "OMGWTFBBQ"
  #     end
  #     puts counter.inspect
  #
  # *pry output*:
  #
  #     [1] pry(main)> counter = 0
  #     => 0
  #     [2] pry(main)> ZTK::RescueRetry.try(:tries => 3, :on => EOFError) do
  #     [2] pry(main)*   counter += 1
  #     [2] pry(main)*   raise EOFError
  #     [2] pry(main)* end
  #     EOFError: EOFError
  #     from (pry):4:in `block in <main>'
  #     [3] pry(main)> puts counter.inspect
  #     3
  #     => nil
  #     [4] pry(main)>
  #     [5] pry(main)> counter = 0
  #     => 0
  #     [6] pry(main)> ZTK::RescueRetry.try(:tries => 3) do
  #     [6] pry(main)*   counter += 1
  #     [6] pry(main)*   raise "OMGWTFBBQ"
  #     [6] pry(main)* end
  #     RuntimeError: OMGWTFBBQ
  #     from (pry):10:in `block in <main>'
  #     [7] pry(main)> puts counter.inspect
  #     3
  #     => nil
  #     [8] pry(main)>
  #     [9] pry(main)> counter = 0
  #     => 0
  #     [10] pry(main)> ZTK::RescueRetry.try(:tries => 3, :on => EOFError) do
  #     [10] pry(main)*   counter += 1
  #     [10] pry(main)*   raise "OMGWTFBBQ"
  #     [10] pry(main)* end
  #     RuntimeError: OMGWTFBBQ
  #     from (pry):16:in `block in <main>'
  #     [11] pry(main)> puts counter.inspect
  #     1
  #     => nil
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
      # @option options [Lambda,Proc] :on_retry (nil) A proc or lambda to call
      #   when we catch an exception and retry.
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
        options.ui.logger.debug { "options=#{options.send(:table).inspect}" }

        !block_given? and Base.log_and_raise(options.ui.logger, RescueRetryError, "You must supply a block!")

        begin
          return block.call
        rescue options.on => e
          if ((options.tries -= 1) > 0)
            options.ui.logger.warn { "Caught #{e.inspect}, we will give it #{options.tries} more tr#{options.tries > 1 ? 'ies' : 'y'}." }

            sleep(options.delay)

            options.on_retry and options.on_retry.call(e)

            retry
          else
            options.ui.logger.fatal { "Caught #{e.inspect} and we have no more tries left, sorry, we have to give up now." }

            raise e
          end
        end

      end

    end

  end

end
