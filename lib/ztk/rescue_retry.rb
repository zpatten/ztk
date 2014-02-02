module ZTK

  # RescueRetry Error Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class RescueRetryError < Error; end

  # RescueRetry Class
  #
  # This class contains an exception handling tool, which will allowing retry
  # of all or specific *Exceptions* based on a set number of attempts to make.
  #
  # The block is yielded and if a valid exception occurs the block will be
  # re-executed for the set number of attempts.
  #
  # *example code*:
  #
  #     counter = 0
  #     ZTK::RescueRetry.try(:tries => 3, :on => EOFError) do
  #       counter += 1
  #       raise EOFError
  #     end
  #     puts counter.inspect
  #
  #     counter = 0
  #     ZTK::RescueRetry.try(:tries => 3) do
  #       counter += 1
  #       raise "OMGWTFBBQ"
  #     end
  #     puts counter.inspect
  #
  #     counter = 0
  #     ZTK::RescueRetry.try(:tries => 3, :on => EOFError) do
  #       counter += 1
  #       raise "OMGWTFBBQ"
  #     end
  #     puts counter.inspect
  #
  # *pry output*:
  #
  #     [1] pry(main)> counter = 0
  #     => 0
  #     [2] pry(main)> ZTK::RescueRetry.try(:tries => 3, :on => EOFError) do
  #     [2] pry(main)*   counter += 1
  #     [2] pry(main)*   raise EOFError
  #     [2] pry(main)* end
  #     EOFError: EOFError
  #     from (pry):4:in `block in <main>'
  #     [3] pry(main)> puts counter.inspect
  #     3
  #     => nil
  #     [4] pry(main)>
  #     [5] pry(main)> counter = 0
  #     => 0
  #     [6] pry(main)> ZTK::RescueRetry.try(:tries => 3) do
  #     [6] pry(main)*   counter += 1
  #     [6] pry(main)*   raise "OMGWTFBBQ"
  #     [6] pry(main)* end
  #     RuntimeError: OMGWTFBBQ
  #     from (pry):10:in `block in <main>'
  #     [7] pry(main)> puts counter.inspect
  #     3
  #     => nil
  #     [8] pry(main)>
  #     [9] pry(main)> counter = 0
  #     => 0
  #     [10] pry(main)> ZTK::RescueRetry.try(:tries => 3, :on => EOFError) do
  #     [10] pry(main)*   counter += 1
  #     [10] pry(main)*   raise "OMGWTFBBQ"
  #     [10] pry(main)* end
  #     RuntimeError: OMGWTFBBQ
  #     from (pry):16:in `block in <main>'
  #     [11] pry(main)> puts counter.inspect
  #     1
  #     => nil
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class RescueRetry

    class << self

      # Rescue and Retry the supplied block.
      #
      # When no options are supplied, if an *Exception* is encounter it is
      # surfaced immediately and no retry is performed.
      #
      # It is advisable to at least leave the *delay* option at 1.  You could
      # optionally set this to 0, but this is generally a bad idea.
      #
      # @param [Hash] options Configuration options hash.
      # @option options [Integer] :tries (1) How many attempts at executing the
      #   block before we give up and surface the *Exception*.
      # @option options [Exception,Array<Exception>] :on (Exception) Watch for
      #   specific exceptions instead of performing retry on all exceptions.
      # @option options [Exception,Array<Exception>] :raise (Exception) Watch
      #   for specific exceptions and do not attempt to retry if they are
      #   raised.
      # @option options [Float,Integer] :delay (1) How long to sleep for between
      #   each retry.
      # @option options [Lambda,Proc] :on_retry (nil) A proc or lambda to call
      #   when we catch an exception and retry.
      #
      # @yield Block should execute the tasks to be rescued and retried if
      #   needed.
      # @return [Object] The return value of the block.
      def try(options={}, &block)
        options = Base.build_config({
          :tries => 1,
          :on => Exception,
          :delay => 1,
          :raise => nil
        }, options)

        !block_given? and Base.log_and_raise(options.ui.logger, RescueRetryError, "You must supply a block!")

        raise_exceptions = [options.raise].flatten.compact
        retry_exceptions = [options.on].flatten.compact

        begin
          return block.call

        rescue *retry_exceptions => e

          options.tries -= 1

          if ((options.tries > 0) && !raise_exceptions.include?(e.class))
            options.ui.logger.warn { "Caught #{e.inspect}, we will give it #{options.tries} more tr#{options.tries > 1 ? 'ies' : 'y'}." }

            sleep(options.delay)

            options.on_retry and options.on_retry.call(e)

            retry
          else
            options.ui.logger.fatal { "Caught #{e.inspect} and we have no more tries left! We have to give up now!" }

            raise e
          end
        end

      end

    end

  end

end
