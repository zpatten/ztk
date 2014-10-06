require 'benchmark'

module ZTK

  # Profiler Error Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class ProfilerError < Error; end

  # Profiler Class
  #
  # A comprehensive timing profiler, this class functions using method_missing
  # to allow the consumer to define timing profiles in an ad hoc manner using
  # a block.
  #
  # *Example Code*:
  #
  #     ZTK::Profiler.reset
  #
  #     ZTK::Profiler.operation_alpha do
  #       ZTK::Profiler.operation_one do
  #         ZTK::Profiler.operation_a do
  #           sleep(0.1)
  #         end
  #         ZTK::Profiler.operation_b do
  #           sleep(0.1)
  #         end
  #         ZTK::Profiler.operation_c do
  #           sleep(0.1)
  #         end
  #       end
  #       ZTK::Profiler.operation_two do
  #         ZTK::Profiler.operation_d do
  #           sleep(0.1)
  #         end
  #         ZTK::Profiler.operation_e do
  #           sleep(0.1)
  #         end
  #         ZTK::Profiler.operation_f do
  #           sleep(0.1)
  #         end
  #       end
  #     end
  #     ZTK::Profiler.operation_beta do
  #       ZTK::Profiler.operation_three do
  #         ZTK::Profiler.operation_a do
  #           sleep(0.1)
  #         end
  #         ZTK::Profiler.operation_b do
  #           sleep(0.1)
  #         end
  #         ZTK::Profiler.operation_c do
  #           sleep(0.1)
  #         end
  #       end
  #     end
  #
  #     ZTK::Profiler.report
  #
  # *Example Output*:
  #
  #     --+ OperationAlpha 0.6070s
  #       |--+ OperationOne 0.3035s
  #       |  |--+ OperationA 0.1011s
  #       |  |--+ OperationB 0.1011s
  #       |  |--+ OperationC 0.1011s
  #       |--+ OperationTwo 0.3035s
  #       |  |--+ OperationD 0.1011s
  #       |  |--+ OperationE 0.1011s
  #       |  |--+ OperationF 0.1011s
  #     --+ OperationBeta 0.3034s
  #       |--+ OperationThree 0.3034s
  #       |  |--+ OperationA 0.1011s
  #       |  |--+ OperationB 0.1011s
  #       |  |--+ OperationC 0.1011s
  #
  #      OperationAlpha: 0.6070s (22.2%)
  #        OperationOne: 0.3035s (11.1%)
  #          OperationA: 0.2022s (7.4%)
  #          OperationB: 0.2022s (7.4%)
  #          OperationC: 0.2022s (7.4%)
  #        OperationTwo: 0.3035s (11.1%)
  #          OperationD: 0.1011s (3.7%)
  #          OperationE: 0.1011s (3.7%)
  #          OperationF: 0.1011s (3.7%)
  #       OperationBeta: 0.3034s (11.1%)
  #      OperationThree: 0.3034s (11.1%)
  #
  #        Nested Time: 2.7306s
  #        Actual Time: 0.9110s
  #      Profiled Time: 0.9105s
  #       Missing Time: 0.0005s
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Profiler

    require 'ztk/profiler/core'
    require 'ztk/profiler/private'
    require 'ztk/profiler/timer'

    extend ZTK::Profiler::Core

  private

    extend ZTK::Profiler::Private

  end

end

