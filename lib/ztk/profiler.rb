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

ZTK::Profiler.reset

ZTK::Profiler.operation_alpha do
  ZTK::Profiler.operation_one do
    ZTK::Profiler.operation_a do
      sleep(0.1)
    end
    ZTK::Profiler.operation_b do
      sleep(0.1)
    end
    ZTK::Profiler.operation_c do
      sleep(0.1)
    end
  end
  ZTK::Profiler.operation_two do
    ZTK::Profiler.operation_d do
      sleep(0.1)
    end
    ZTK::Profiler.operation_e do
      sleep(0.1)
    end
    ZTK::Profiler.operation_f do
      sleep(0.1)
    end
  end
end
ZTK::Profiler.operation_beta do
  ZTK::Profiler.operation_three do
    ZTK::Profiler.operation_a do
      sleep(0.1)
    end
    ZTK::Profiler.operation_b do
      sleep(0.1)
    end
    ZTK::Profiler.operation_c do
      sleep(0.1)
    end
  end
end

ZTK::Profiler.report
