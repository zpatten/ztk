module ZTK
  class Profiler

    # Profiler Private Functionality
    module Private

      def report_timers(options={}, parent=nil, depth=0)
        return false if (Timer.count == 0)

        child_timers = Timer.timers_by_parent[parent]
        child_timers.each do |timer|
          prefix = ('  |' * (depth))

          options.ui.stdout.print("%s--+ %s %0.4fs\n" % [ prefix, timer.name.to_s.camelize, timer.benchmark ])

          report_timers(options, timer, (depth + 1))
        end

        true
      end

      def report_timer_totals(options={})
        return false if (Timer.count == 0)

        result                = Hash.new
        timer_names           = Timer.timers_by_name.keys.compact
        timer_names_camelize  = timer_names.map(&:to_s).map(&:camelize)
        max_timer_name_length = (timer_names_camelize.map(&:length).max + 1)
        timer_names.each do |timer_name|
          benchmark_nested   = Timer.timers_by_name[timer_name].map(&:benchmark_nested).reduce(&:+)
          result[timer_name] = benchmark_nested

          options.ui.stdout.print("%#{max_timer_name_length}s: %0.4fs (%-3.1f%%)\n" % [timer_name.to_s.camelize, benchmark_nested, (benchmark_nested / Timer.benchmark_nested_total) * 100])
        end
        result
      end

      def report_totals(options={})
        return false if (Timer.count == 0)

        times = {
          'Nested Time'   => Timer.benchmark_nested_total,
          'Actual Time'   => Profiler.total_time,
          'Profiled Time' => Timer.total_time,
          'Missing Time'  => (Profiler.total_time - Timer.total_time)
        }
        max_key_length = (times.keys.map(&:length).max + 1)
        time_format    = "%#{max_key_length}s: %0.4fs\n"

        times.each do |name, time|
          options.ui.stdout.print(time_format % [ name, time ])
        end
      end

    end

  end
end
