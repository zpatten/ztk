module ZTK
  class Profiler
    class Timer

      # Profiler Timer Class Functionality
      module ClassMethods

        @@timers                 ||= Array.new
        @@timers_by_name         ||= Hash.new { |hash, key| hash[key] = Array.new }
        @@timers_by_parent       ||= Hash.new { |hash, key| hash[key] = Array.new }
        @@benchmark_total        ||= nil
        @@benchmark_nested_total ||= nil

        def timers
          @@timers
        end

        def timers_by_parent
          @@timers_by_parent
        end

        def timers_by_name
          @@timers_by_name
        end

        def add(timer)
          @@timers << timer

          @@timers_by_parent[timer.parent] << timer
          @@timers_by_name[timer.name] << timer

          true
        end

        def reset
          @@timers           = Array.new
          @@timers_by_name   = Hash.new { |hash, key| hash[key] = Array.new }
          @@timers_by_parent = Hash.new { |hash, key| hash[key] = Array.new }

          true
        end

        def nested_time(name=nil, parent=nil)
          result = 0.0

          child_timers = @@timers_by_parent[parent]
          child_timers.each do |child_timer|
            if (child_timer.name == name)
              result += child_timer.benchmark_nested
            end
            result += nested_time(name, child_timer)
          end

          result
        end

        def benchmark_total
          @@benchmark_total ||= @@timers.map(&:benchmark).reduce(&:+)
          @@benchmark_total
        end

        def benchmark_nested_total
          @@benchmark_nested_total ||= @@timers.map(&:benchmark_nested).reduce(&:+)
          @@benchmark_nested_total
        end

        def total_time
          @@total_time ||= @@timers_by_parent[nil].map(&:benchmark).reduce(&:+)
          @@total_time
        end

      end

    end
  end
end
