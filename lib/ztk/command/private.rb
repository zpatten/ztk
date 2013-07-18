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
      def log_header(what, char="=")
        count = 16
        sep = (char * count)
        header = [sep, "[ #{tag} >>> #{what} ]", sep].join
        "#{header}\n"
      end

    end

  end
end
