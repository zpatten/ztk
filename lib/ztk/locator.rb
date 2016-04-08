module ZTK

  # Locator Error Class
  #
  # @author Zachary Patten <zpatten AT jovelabs DOT io>
  class LocatorError < Error; end

  # @author Zachary Patten <zpatten AT jovelabs DOT io>
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

      # Returns the root for the filesystem we are operating on.  Ignores
      # mount boundries on *nix.
      #
      # For all flavors of *nix this should always return "/".
      #
      # Windows should expect something similar to "C:\".
      #
      # @return [String] The root path of the file-system.  For unix this should
      #   always be "/".  For windows this should be something like "C:\".
      def root
        Dir.pwd.split(File::SEPARATOR).first
      end

    end

  end

end
