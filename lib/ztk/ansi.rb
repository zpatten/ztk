module ZTK

  # ANSI Error Class
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class ANSIError < Error; end

  # ANSI Mixin Module
  #
  # Standard use is to mix this module into String.
  #
  # @example Mix this module into String to enable easy ANSI coloring methods like:
  #   "bold red".red.bold
  #
  # @example Or
  #   "green".green
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  module ANSI

    # Defines our ANSI color codes
    ANSI_COLORS = {
      :black   => 30,
      :red     => 31,
      :green   => 32,
      :yellow  => 33,
      :blue    => 34,
      :magenta => 35,
      :cyan    => 36,
      :white   => 37
    }

    # @!method black(string=nil, &block)
    #   Sets the foreground color to black for the supplied string.
    #   @param [String] string (nil) The string to operate on.
    #   @yieldreturn [String] The string to operate on.
    #   @return [String] The colored string.
    #
    # @!method red(string=nil, &block)
    #   Sets the foreground color to red for the supplied string.
    #   @param [String] string (nil) The string to operate on.
    #   @yieldreturn [String] The string to operate on.
    #   @return [String] The colored string.
    #
    # @!method green(string=nil, &block)
    #   Sets the foreground color to green for the supplied string.
    #   @param [String] string (nil) The string to operate on.
    #   @yieldreturn [String] The string to operate on.
    #   @return [String] The colored string.
    #
    # @!method yellow(string=nil, &block)
    #   Sets the foreground color to yellow for the supplied string.
    #   @param [String] string (nil) The string to operate on.
    #   @yieldreturn [String] The string to operate on.
    #   @return [String] The colored string.
    #
    # @!method blue(string=nil, &block)
    #   Sets the foreground color to blue for the supplied string.
    #   @param [String] string (nil) The string to operate on.
    #   @yieldreturn [String] The string to operate on.
    #   @return [String] The colored string.
    #
    # @!method magenta(string=nil, &block)
    #   Sets the foreground color to magenta for the supplied string.
    #   @param [String] string (nil) The string to operate on.
    #   @yieldreturn [String] The string to operate on.
    #   @return [String] The colored string.
    #
    # @!method cyan(string=nil, &block)
    #   Sets the foreground color to cyan for the supplied string.
    #   @param [String] string (nil) The string to operate on.
    #   @yieldreturn [String] The string to operate on.
    #   @return [String] The colored string.
    #
    # @!method white(string=nil, &block)
    #   Sets the foreground color to white for the supplied string.
    #   @param [String] string (nil) The string to operate on.
    #   @yieldreturn [String] The string to operate on.
    #   @return [String] The colored string.

    # Defines our ANSI attribute codes
    ANSI_ATTRIBUTES = {
      :normal => 0,
      :bold   => 1
    }

    # @!method normal(string=nil, &block)
    #   Sets the foreground color to normal for the supplied string.
    #   @param [String] string (nil) The string to operate on.
    #   @yieldreturn [String] The string to operate on.
    #   @return [String] The colored string.
    #
    # @!method bold(string=nil, &block)
    #   Sets the foreground color to bold for the supplied string.
    #   @param [String] string (nil) The string to operate on.
    #   @yieldreturn [String] The string to operate on.
    #   @return [String] The colored string.

    # Defines a RegEx for stripping ANSI codes from strings
    ANSI_REGEX = /\e\[(?:(?:[349]|10)[0-7]|[0-9]|[34]8;5;\d{1,3})?m/

    # Build ANSI Methods
    #
    # Dynamicly constructs our color methods based on the ANSI code hash passed
    # in.
    #
    # @param [Hash] hash A hash where the keys represent the method names and
    #   the values are the ANSI codes.
    # @return [Boolean] True if successful.
    def build_ansi_methods(hash)
      hash.each do |key, value|
        define_method(key) do |string=nil, &block|
          result = Array.new

          result << %(\e[#{value}m)
          if block_given?
            result << block.call
          elsif string.respond_to?(:to_str)
            result << string.to_str
          elsif respond_to?(:to_str)
            result << to_str
          else
            return result
          end
          result << %(\e[0m)

          result.join
        end
      end

      true
    end

    # Uncolor String
    #
    # Removes ANSI code sequences from a string.
    #
    # @param [String] string (nil) The string to operate on.
    # @yieldreturn [String] The string to operate on.
    # @return [String] The supplied string stripped of ANSI codes.
    def uncolor(string=nil, &block)
      if block_given?
        block.call.to_str.gsub(ANSI_REGEX, '')
      elsif string.respond_to?(:to_str)
        string.to_str.gsub(ANSI_REGEX, '')
      elsif respond_to?(:to_str)
        to_str.gsub(ANSI_REGEX, '')
      else
        ''
      end
    end

    extend self

    build_ansi_methods(ANSI_COLORS)
    build_ansi_methods(ANSI_ATTRIBUTES)

  end

end
