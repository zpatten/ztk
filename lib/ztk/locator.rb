module ZTK

  # ZTK::Locator Error Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class LocatorError < Error; end

  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Locator

    class << self

      # Locate a file or directory
      #
      # Attempts to locate the file or directory supplied, starting with
      # the current working directory and crawling it up looking for a match
      # at each step of the way.
      #
      # @param [String,Array<String>] args A string or array of strings to
      #   attempt to locate.
      #
      # @return [String] The expanded path to the located entry.
      def find(*args)
        pwd = Dir.pwd.split(File::SEPARATOR)

        (pwd.length - 1).downto(0) do |i|
          candidate = File.expand_path(File.join(pwd[0..i], args))
          return candidate if File.exists?(candidate)
        end

        raise LocatorError, "Could not locate '#{File.join(args)}'!"
      end

    end

  end

end
