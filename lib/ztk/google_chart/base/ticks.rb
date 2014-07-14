module ZTK
  module GoogleChart
    class Base

      module Ticks

        def tick_seed(start_time, end_time, unit)
          start_time = start_time.dup
          ticks = Array.new

          loop do
            ticks << date_scale(unit, start_time)
            start_time += 1.send(unit)
            break if (start_time > end_time)
          end

          ticks
        end

      end

    end
  end
end
