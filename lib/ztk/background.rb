require 'base64'

module ZTK

  # Background Error Class
  #
  # @author Zachary Patten <zpatten AT jovelabs DOT io>
  class BackgroundError < Error; end

  # Background Processing Class
  #
  # This class can be used to easily run a linear process in a background manner.
  #
  # The before fork callback is called once in the parent process.
  #
  # The after fork callback is called twice, once in the parent process and once
  # in the child process.
  #
  # @example Run a background process which simply sleeps illustrating the callback hooks:
  #
  #     a_callback = Proc.new do |pid|
  #       puts "Hello from After Callback - PID #{pid}"
  #     end
  #
  #     b_callback = Proc.new do |pid|
  #       puts "Hello from Before Callback - PID #{pid}"
  #     end
  #
  #     background = ZTK::Background.new
  #     background.config do |config|
  #       config.before_fork = b_callback
  #       config.after_fork = a_callback
  #     end
  #
  #     pid = background.process do
  #       sleep(1)
  #     end
  #     puts pid.inspect
  #
  #     background.wait
  #     puts background.result.inspect
  #
  # @author Zachary Patten <zpatten AT jovelabs DOT io>
  class Background < ZTK::Base

    # Result Set
    attr_accessor :pid, :result

    # @param [Hash] configuration Configuration options hash.
    #
    def initialize(configuration={})
      super(configuration)

      @result = nil
      GC.respond_to?(:copy_on_write_friendly=) and GC.copy_on_write_friendly = true
    end

    # Process in background.
    #
    # @yield Block should execute tasks to be performed in background.
    # @yieldreturn [Object] Block can return any object to be marshalled back to
    #   the parent processes.
    # @return [Integer] Returns the pid of the child process forked.
    #
    def process(&block)
      !block_given? and log_and_raise(BackgroundError, "You must supply a block to the process method!")

      @child_reader, @parent_writer = IO.pipe
      @parent_reader, @child_writer = IO.pipe

      config.before_fork and config.before_fork.call(Process.pid)
      @pid = Process.fork do
        config.after_fork and config.after_fork.call(Process.pid)

        @parent_writer.close
        @parent_reader.close

        STDOUT.reopen("/dev/null", "a")
        STDERR.reopen("/dev/null", "a")
        STDIN.reopen("/dev/null")

        if !(data = block.call).nil?
          config.ui.logger.debug { "write(#{data.inspect})" }
          @child_writer.write(Base64.encode64(Marshal.dump(data)))
        end

        @child_reader.close
        @child_writer.close
        Process.exit!(0)
      end
      config.after_fork and config.after_fork.call(Process.pid)

      @child_reader.close
      @child_writer.close

      @pid
    end

    # Wait for the background process to finish.
    #
    # If a process successfully finished, it's return value from the *process*
    # block is stored into the result set.
    #
    # It's advisable to use something like the *at_exit* hook to ensure you don't
    # leave orphaned processes.  For example, in the *at_exit* hook you could
    # call *wait* to block until the child process finishes up.
    #
    # @return [Array<pid, status, data>] An array containing the pid,
    #   status and data returned from the process block.  If wait2() fails nil
    #   is returned.
    #
    def wait
      config.ui.logger.debug { "wait" }
      pid, status = (Process.wait2(@pid) rescue nil)
      if !pid.nil? && !status.nil?
        data = (Marshal.load(Base64.decode64(@parent_reader.read.to_s)) rescue nil)
        config.ui.logger.debug { "read(#{data.inspect})" }
        !data.nil? and @result = data

        @parent_reader.close
        @parent_writer.close

        return [pid, status, data]
      end
      nil
    end

    def alive?
      (Process.getpgid(@pid).is_a?(Integer) rescue false)
    end

    def dead?
      !alive?
    end

  end

end
