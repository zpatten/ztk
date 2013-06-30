module ZTK
  class Command

    # Command Upload Functionality
    module Upload

      # Not Supported
      # @raise [CommandError] Not Supported
      def upload(*args)
        log_and_raise(CommandError, "Not Supported")
      end

    end

  end
end
