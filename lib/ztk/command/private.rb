module ZTK
  class Command

    # Command Private Functionality
    module Private

      # Returns a string in the format of "user@hostname" for the current
      # shell.
      def tag
        @@hostname ||= Socket.gethostname.split('.').first.strip
        "#{ENV['USER']}@#{@@hostname}"
      end

      # Formats a header suitable for writing to the direct logger when logging
      # sessions.
      def log_header(what)
        count = 8
        sep = ("=" * count)
        header = [sep, "[ #{what} ]", sep, "[ #{tag} ]", sep, "[ #{what} ]", sep].join
        "#{header}\n"
      end

    end

  end
end
