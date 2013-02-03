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

  # ZTK::Spinner Error Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class SpinnerError < Error; end

  # ZTK Spinner Class
  #
  # This class can be used to display an "activity indicator" to a user while
  # a task is executed in the supplied block.  This indicator takes the form
  # of a spinner.
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Spinner

    class << self

      # Spinner Character Set
      CHARSET = %w( | / - \\ )

      # UI Spinner
      #
      # Displays a "spinner" while executing the supplied block.  It is
      # advisable that no output is sent to the console during this time.
      #
      # @param [Hash] options Configuration options hash.
      # @option options [Float,Integer] :step (0.1) How long to sleep for in
      #   between cycles, while cycling through the *CHARSET*.
      #
      # @yield Block should execute the tasks for which they wish the user to
      #   have a false sense of security in the fact that something is actually
      #   taking place "behind the scenes".
      # @return [Object] The return value of the block.
      #
      # @author Zachary Patten <zachary@jovelabs.net>
      # @author Stephen Nelson-Smith <stephen@atalanta-systems.com>
      def spin(options={}, &block)
        options = Base.build_config({
          :step => 0.1
        }.merge(options))
        options.ui.logger.debug { "options(#{options.send(:table).inspect})" }

        !block_given? and Base.log_and_raise(options.ui.logger, SpinnerError, "You must supply a block!")

        count = 0
        spinner = Thread.new do
          while count do
            options.ui.stdout.print(CHARSET[(count += 1) % CHARSET.length])
            options.ui.stdout.print("\b")
            options.ui.stdout.respond_to?(:flush) and options.ui.stdout.flush
            sleep(options.step)
          end
        end
        yield.tap do
          count = false
          spinner.join
        end
      end

    end

  end

end
