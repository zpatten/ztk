module ZTK

  # PTY Error Class
  #
  # @author Zachary Patten <zpatten AT jovelabs DOT io>
  class PTYError < Error; end

  # Ruby PTY Class Wrapper
  #
  # Wraps the Ruby PTY class, providing better functionality.
  #
  # @author Zachary Patten <zpatten AT jovelabs DOT io>
  class PTY
    require 'pty'

    class << self

      # Execute a process via a ruby-based PTY.
      #
      # @param [Array] args An argument splat to be passed to PTY::spawn
      #
      # @return [Object] Returns the $? object.
      def spawn(*args, &block)
        begin
          ::PTY.spawn(*args) do |reader, writer, pid|
            begin
              block_given? and yield(reader, writer, pid)
            rescue Errno::EIO
            ensure
              ::Process.wait(pid)
            end
          end
        rescue ::PTY::ChildExited
        end

        true
      end

    end

  end

end
