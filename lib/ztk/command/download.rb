module ZTK
  class Command

    # Command Download Functionality
    module Download

      # Not Supported
      # @raise [CommandError] Not Supported
      def download(*args)
        log_and_raise(CommandError, "Not Supported")
      end

    end

  end
end
