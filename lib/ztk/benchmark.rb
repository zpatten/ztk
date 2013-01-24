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

      def bench(options={}, &block)
        !block_given? and raise BenchmarkError, "You must supply a block!"

        options = { :stdout => STDOUT, :logger => $logger, :message => nil, :mark => nil }.merge(options)

        stdout = options[:stdout]
        logger = options[:logger]
        message = options[:message]
        mark = options[:mark]

        logger and logger.debug { options.inspect }

        (!message.nil? && !mark.nil?) and stdout.print("#{message} ")
        benchmark = ::Benchmark.realtime do
          if message.nil?
            yield
          else
            ZTK::Spinner.spin do
              yield
            end
          end
        end

        (!message.nil? && !mark.nil?) and stdout.print("#{mark}\n" % benchmark)
        logger and logger.info { "#{message} #{mark}" }

        benchmark
      end

    end

  end

end
