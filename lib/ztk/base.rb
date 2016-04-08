require 'ostruct'

module ZTK

  # Base Error Class
  #
  # @author Zachary Patten <zpatten AT jovelabs DOT io>
  class BaseError < Error; end

  # Base Class
  #
  # This is the base class inherited by most of the other classes in this
  # library.  It provides a standard set of features to control STDOUT, STDERR
  # and STDIN, a configuration mechanism and logging mechanism.
  #
  # You should never interact with this class directly; you should inherit it
  # and extend functionality as appropriate.
  #
  # @author Zachary Patten <zpatten AT jovelabs DOT io>
  class Base

    class << self

      # Builds Configuration Object
      #
      # Builds an OpenStruct backed configuration object.
      #
      # @param [Hash] config Configuration options hash.
      # @option config [ZTK::UI] :ui Instance of ZTK:UI to be used for
      #   console IO and logging.
      # @param [Hash] override Override configuration hash.
      def build_config(config={}, override={})
        config = OpenStruct.new({
          :ui => ::ZTK::UI.new
        }.merge(hash_config(config)).merge(hash_config(override)))

        config.ui.logger.debug { "config=#{config.send(:table).inspect}" }

        config
      end

      # Hash Configuration
      #
      # Ensure a configuration is of object type Hash.  Since we use OpenStructs
      # we need to convert back to hash from time to time.
      def hash_config(config={})
        if config.is_a?(OpenStruct)
          config.send(:table)
        else
          config
        end
      end

      # Logs an exception and then raises it.
      #
      # @param [Logger] logger An instance of a class based off the Ruby
      #   *Logger* class.
      # @param [Exception] exception The exception class to raise.
      # @param [String] message The message to display with the exception.
      # @param [Integer] shift (1) How many places to shift the caller stack in
      #   the log statement.
      def log_and_raise(logger, exception, message, shift=1)
        if logger.is_a?(ZTK::Logger)
          logger.shift(:fatal, shift) { "EXCEPTION: #{exception.inspect} - #{message.inspect}" }
        else
          logger.fatal { "EXCEPTION: #{exception.inspect} - #{message.inspect}" }
        end
        raise exception, message
      end

    end

    # @param [Hash] config Initial configuration hash.
    # @param [Hash] override Override configuration hash.
    def initialize(config={}, override={})
      @config = Base.build_config(config, override)
    end

    # Configuration OpenStruct accessor method.
    #
    # If no block is given, the method will return the configuration OpenStruct
    # object.  If a block is given, the block is yielded with the configuration
    # OpenStruct object.
    #
    # @yieldparam [OpenStruct] config The configuration OpenStruct object.
    # @return [OpenStruct] The configuration OpenStruct object.
    def config(&block)
      if block_given?
        block.call(@config)
      else
        @config
      end
    end

    # Logs an exception and then raises it.
    #
    # @see Base.log_and_raise
    #
    # @param [Exception] exception The exception class to raise.
    # @param [String] message The message to display with the exception.
    # @param [Integer] shift (2) How many places to shift the caller stack in
    #   the log statement.
    def log_and_raise(exception, message, shift=2)
      Base.log_and_raise(config.ui.logger, exception, message, shift)
    end

    # Direct logging method.
    #
    # This method provides direct writing of data to the current log device.
    # This is mainly used for pushing STDOUT and STDERR into the log file in
    # ZTK::SSH and ZTK::Command, but could easily be used by other classes.
    #
    # The value returned in the block is passed down to the logger specified in
    # the classes configuration.
    #
    # @param [Symbol] log_level This should be any one of [:debug, :info, :warn, :error, :fatal].
    # @yield No value is passed to the block.
    # @yieldreturn [String] The message to log.
    def direct_log(log_level, &blocK)
      @config.ui.logger.nil? and raise BaseError, "You must supply a logger for direct logging support!"

      if !block_given?
        log_and_raise(BaseError, "You must supply a block to the log method!")
      elsif (@config.ui.logger.level <= ::Logger.const_get(log_level.to_s.upcase))
        @config.ui.logger << ZTK::ANSI.uncolor(yield)
      end
    end

  end

end
