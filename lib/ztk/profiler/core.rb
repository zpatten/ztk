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
        results = Array.new
        options = Base.build_config({}, options)

        stop

        if (Timer.count > 0)
          report_timers(options) and options.ui.stdout.puts
          results << report_timer_totals(options)
          results.last and options.ui.stdout.puts
          results << report_totals(options)
        else
          options.ui.stderr.puts("Nothing was profiled!")
          results = [ nil, nil ]
        end

        results
      end

    end

  end
end
