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

  # ZTK Benchmark Class
  #
  # This class contains a benchmarking tool which doubles to supply indications
  # of activity to the console user during long running tasks.
  #
  # It can be run strictly for benchmarking (the default) or if supplied with
  # the appropriate options it will display output to the user while
  # benchmarking the supplied block.
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Benchmark

    class << self

      # Benchmark the supplied block.
      #
      # If *message* and *mark* options are used, then the *message* text will
      # be displayed to the user.  The the supplied *block* is yielded inside
      # a *ZTK::Spinner.spin* call.  This will provide the spinning cursor while
      # the block executes.  It is advisable to not have output sent to the
      # console during this period.
      #
      # Once the block finishes executing, the *mark* text is displayed with
      # the benchmark supplied to it as a sprintf option.  One could use "%0.4f"
      # in a *String* for example to get the benchmark time embedded in it
      # (see Kernel#sprintf).
      #
      # @param [Hash] options Configuration options hash.
      # @option options [String] :message Instance of IO to be used for STDOUT.
      # @option options [String] :mark Instance of IO to be used for STDERR.
      #
      # @yield Block should execute the tasks to be benchmarked.
      # @yieldreturn [Object] The return value of the block is ignored.
      # @return [Float] The benchmark time.
      def bench(options={}, &block)
        options = Base.build_config(options)
        options.logger.debug { "options=#{options.send(:table).inspect}" }

        !block_given? and Base.log_and_raise(options.logger, BenchmarkError, "You must supply a block!")

        check = [options.message, options.mark]
        (check.any?{ |z| !z.nil? } && !check.all?{ |z| !z.nil? }) and Base.log_and_raise(options.logger, BenchmarkError, "You must supply both a message and a mark!")

        (options.message && options.mark) and options.stdout.print("#{options.message} ")
        benchmark = ::Benchmark.realtime do
          if (options.message && options.mark)
            ZTK::Spinner.spin(Base.sanitize_config(options)) do
              yield
            end
          else
            yield
          end
        end

        (options.message && options.mark) and options.stdout.print("#{options.mark}\n" % benchmark)
        options.logger.info { "#{options.message} #{options.mark}" % benchmark }

        benchmark
      end

    end

  end

end
