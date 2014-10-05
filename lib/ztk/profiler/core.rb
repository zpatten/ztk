module ZTK
  class Profiler

    # Profiler Core Functionality
    module Core
      require 'ztk/ui'

      @@start_time  ||= nil
      @@end_time    ||= nil
      @@timer_stack ||= Array.new

      def start
        reset

        true
      end

      def stop
        @@end_time ||= Time.now.utc

        true
      end

      def reset
        @@start_time  = Time.now.utc
        @@end_time    = nil
        @@timer_stack = Array.new
        Timer.reset

        true
      end

      def method_missing(method_name, *method_args)
        raise "You must supply a block to the profiler method #{method_name.inspect}!" unless block_given?

        @@start_time ||= Time.now.utc

        result = nil
        timer  = Timer.new(method_name, @@timer_stack.last)

        @@timer_stack.push(timer)
        timer.benchmark = ::Benchmark.realtime do
          result = yield
        end
        @@timer_stack.pop

        result
      end

      def total_time
        stop
        @@end_time - @@start_time
      end

      def report(options={})
        options = Base.build_config({}, options)

        stop

        results = Array.new

        report_timers(options)
        options.ui.stdout.puts
        results << report_timer_totals(options)
        options.ui.stdout.puts
        results << report_totals(options)

        results
      end

    end

  end
end
