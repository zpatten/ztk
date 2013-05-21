require 'ostruct'

module ZTK

  # Spinner Error Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class SpinnerError < Error; end

  # Spinner Class
  #
  # This class can be used to display an "activity indicator" to a user while
  # a task is executed in the supplied block.  This indicator takes the form
  # of a spinner.
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Spinner

    class << self

      # Spinner Character Set
      CHARSET = %w( | / - \\ )

      # UI Spinner
      #
      # Displays a "spinner" while executing the supplied block.  It is
      # advisable that no output is sent to the console during this time.
      #
      # @param [Hash] options Configuration options hash.
      # @option options [Float,Integer] :step (0.1) How long to sleep for in
      #   between cycles, while cycling through the *CHARSET*.
      #
      # @yield Block should execute the tasks for which they wish the user to
      #   have a false sense of security in the fact that something is actually
      #   taking place "behind the scenes".
      # @return [Object] The return value of the block.
      #
      # @author Zachary Patten <zachary AT jovelabs DOT com>
      # @author Stephen Nelson-Smith <stephen@atalanta-systems.com>
      def spin(options={}, &block)
        options = Base.build_config({
          :step => 0.1
        }.merge(options))
        options.ui.logger.debug { "options(#{options.send(:table).inspect})" }

        !block_given? and Base.log_and_raise(options.ui.logger, SpinnerError, "You must supply a block!")

        count = 0

        spinner = Thread.new do
          while (count >= 0) do
            options.ui.stdout.print(CHARSET[(count += 1) % CHARSET.length])
            options.ui.stdout.print("\b")
            options.ui.stdout.respond_to?(:flush) and options.ui.stdout.flush
            sleep(options.step)
          end
        end

        yield.tap do
          count = -100
          spinner.join
        end
      end

    end

  end

end
