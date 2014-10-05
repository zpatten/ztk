module ZTK
  class Profiler

    # Profiler Timer Functionality
    class Timer
      require 'ztk/profiler/timer/class_methods'

      extend ZTK::Profiler::Timer::ClassMethods

      attr_accessor :name
      attr_accessor :parent
      attr_accessor :benchmark

      def initialize(name, parent=nil)
        self.name   = name
        self.parent = parent

        self.class.add(self)
      end

      def nested_time
        @nested_time ||= self.class.nested_time(self.name, self)
        @nested_time
      end

      def benchmark_nested
        (self.benchmark - self.nested_time)
      end

    end

  end
end
