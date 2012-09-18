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
  # @author Stephen Nelson-Smith <stephen@atalanta-systems.com>
  class SpinnerError < Error; end

  # Spinner Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  # @author Stephen Nelson-Smith <stephen@atalanta-systems.com>
  class Spinner

    class << self

      def spin(stdout=$stdout)
        charset = %w( | / - \\ )
        count = 0
        spinner = Thread.new do
          while count do
            stdout.print(charset[(count += 1) % charset.length])
            stdout.respond_to?(:flush) and stdout.flush
            sleep(0.25)
            stdout.print("\b")
            stdout.respond_to?(:flush) and stdout.flush
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
