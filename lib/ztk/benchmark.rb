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
require 'benchmark'

module ZTK

  # ZTK::Benchmark Error Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class BenchmarkError < Error; end

  # Benchmark Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Benchmark

    class << self

      def bench(message=nil, stdout=STDOUT)
        !message.nil? and print("#{message} ")
        mark = ::Benchmark.realtime do
          if message.nil?
            yield
          else
            ZTK::Spinner.spin do
              yield
            end
          end
        end
        !message.nil? and puts("completed in %0.4f seconds.\n" % mark)

        mark
      end

    end

  end

end
