module ZTK
  module GoogleChart
    class Base

      module Dates

        DATE_HELPERS = {
          :second => -1,
          :minute => -2,
          :hour => -3,
          :day => -4,
          :month => -5,
          :year => -6
        }

        def date_scale(scale, *args)
          case scale
          when :year then
            send(:date_month, *args)
          when :month, :week then
            send(:date_day, *args)
          when :day then
            send(:date_hour, *args)
          when :hour then
            send(:date_minute, *args)
          when :minute then
            send(:date_second, *args)
          end
        end

        def date_seed(start_time, end_time, unit, default)
          start_time = start_time.dup
          timeline = Hash.new

          scale = case unit
          when :year then
            :month
          when :month, :week then
            :day
          when :day then
            :hour
          when :hour then
            :minute
          when :minute then
            :second
          end

          loop do
            timeline.merge!(date_scale(unit, start_time) => default.dup)
            start_time += 1.send(scale)
            break if (start_time > end_time)
          end

          timeline
        end

        def date_wrapper(value)
          "new Date(#{value})"
        end

        def date_format(*args)
          %w( %Y %%d %-d %-H %-M %-S )[*args].join(',')
        end

        DATE_HELPERS.each do |unit, offset|
          method_name = "date_#{unit}".downcase.to_sym
          define_method(method_name) do |date=Time.now.utc|
            date_wrapper(date.strftime(date_format(0..offset)) % [ (date.month - 1) ])
          end
        end

      end

    end
  end
end
