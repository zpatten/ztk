require 'base64'
require 'timeout'
require 'zlib'

module ZTK

  # Parallel Error Class
  #
  # @author Zachary Patten <zpatten AT jovelabs DOT io>
  class ParallelError < Error; end

  # Parallel Processing Class
  #
  # This class can be used to easily run iterative and linear processes in a parallel manner.
  #
  # The before fork callback is called once in the parent process.
  #
  # The after fork callback is called twice, once in the parent process and once
  # in the child process.
  #
  # @example Parallel processing with callbacks
  #
  #     a_callback = Proc.new do |pid|
  #       puts "Hello from After Callback - PID #{pid}"
  #     end
  #
  #     b_callback = Proc.new do |pid|
  #       puts "Hello from Before Callback - PID #{pid}"
  #     end
  #
  #     parallel = ZTK::Parallel.new
  #     parallel.config do |config|
  #       config.before_fork = b_callback
  #       config.after_fork = a_callback
  #     end
  #
  #     puts Process.pid.inspect
  #
  #     3.times do |x|
  #       parallel.process do
  #         x
  #       end
  #     end
  #
  #     parallel.waitall
  #     puts parallel.results.inspect
  #
  # @author Zachary Patten <zpatten AT jovelabs DOT io>
  class Parallel < ZTK::Base

    class Break < ParallelError; end
    class Timeout < ParallelError; end

    # Tests if we can marshal an exception via the results; otherwise creates
    # an exception we can marshal.
    class ExceptionWrapper
      attr_reader :exception

      def initialize(exception)
        dumpable = (Marshal.dump(exception) rescue nil)
        dumpable.nil? and (exception = RuntimeError.new(exception.inspect))
        @exception = exception
      end
    end

    # Default Maximum Number of Forks
    MAX_FORKS = case RUBY_PLATFORM
    when /darwin/ then
      (%x( sysctl hw.ncpu ).strip.split(':').last.strip.to_i - 1)
    when /linux/ then
      (%x( grep -c processor /proc/cpuinfo ).strip.to_i - 1)
    end

    # Platforms memory capacity in bytes
    MAX_MEMORY = case RUBY_PLATFORM
    when /darwin/ then
      %x( sysctl hw.memsize ).strip.split[1].to_i
    when /linux/ then
      (%x( grep MemTotal /proc/meminfo ).strip.split[1].to_i * 1024)
    end

    # Child process timeout in seconds; <= 0 to disable
    DEFAULT_CHILD_TIMEOUT = 0

    # Which signals we want to trap for child signaling
    trapped_signals = %w( term int hup )
    trapped_signals << "kill" if RUBY_VERSION < "2.2.0"
    TRAPPED_SIGNALS = trapped_signals.map(&:upcase)

    # Result Set
    attr_accessor :results

    # @param [Hash] configuration Configuration options hash.
    # @option config [Integer] :max_forks Maximum number of forks to use.
    # @option config [Proc] :before_fork (nil) Proc to call before forking.
    # @option config [Proc] :after_fork (nil) Proc to call after forking.
    def initialize(configuration={})
      super({
        :max_forks        => MAX_FORKS,
        :raise_exceptions => true,
        :child_timeout    => DEFAULT_CHILD_TIMEOUT
      }, configuration)

      (config.max_forks < 1) and log_and_raise(ParallelError, "max_forks must be equal to or greater than one!")

      @forks = Array.new
      @results = Array.new
      GC.respond_to?(:copy_on_write_friendly=) and GC.copy_on_write_friendly = true

      TRAPPED_SIGNALS.each do |signal|
        Signal.trap(signal) do
          $stderr.puts("SIG#{signal} received by PID##{Process.pid}; signaling child processes...")

          signal_all(signal)

          (signal == "INT") or exit!(1)
        end
      end

      Kernel.at_exit do
        signal_all('TERM')
      end
    end

    # Process in parallel.
    #
    # @yield Block should execute tasks to be performed in parallel.
    # @yieldreturn [Object] Block can return any object to be marshalled back to
    #   the parent processes result set.
    # @return [Integer] Returns the pid of the child process forked.
    def process(&block)
      !block_given? and log_and_raise(ParallelError, "You must supply a block to the process method!")

      config.ui.logger.debug { "forks(#{@forks.inspect})" }

      while (@forks.count >= config.max_forks) do
        wait
      end

      child_reader, parent_writer = IO.pipe
      parent_reader, child_writer = IO.pipe

      config.before_fork and config.before_fork.call(Process.pid)
      pid = Process.fork do
        begin
          TRAPPED_SIGNALS.each { |signal| Signal.trap(signal) { } }

          parent_writer.close
          parent_reader.close

          config.after_fork and config.after_fork.call(Process.pid)

          data = nil
          begin
            ::Timeout.timeout(config.child_timeout, ZTK::Parallel::Timeout) do
              data = block.call
            end
          rescue Exception => e
            config.ui.logger.fatal { e.message }
            e.backtrace.each do |line|
              config.ui.logger << "#{line}\n"
            end
            data = ExceptionWrapper.new(e)
          end

          if !data.nil?
            begin
              encoded_data = Base64.encode64(Zlib::Deflate.deflate(Marshal.dump(data)))
              config.ui.logger.debug { "write(#{encoded_data.length}B: #{data.inspect})" }
              child_writer.write(encoded_data)
            rescue Exception => e
              config.ui.logger.warn { "Exception while writing data to child_writer! - #{e.inspect}" }
            end
          end

        rescue Exception => e
          config.ui.logger.fatal { "Exception in Child Process Handler: #{e.inspect}" }

        ensure
          child_reader.close rescue nil
          child_writer.close rescue nil

          Process.exit!(0)
        end
      end
      config.after_fork and config.after_fork.call(Process.pid)

      child_reader.close
      child_writer.close

      fork = {:reader => parent_reader, :writer => parent_writer, :pid => pid}
      @forks << fork

      pid
    end

    # Wait for a single fork to finish.
    #
    # If a fork successfully finishes, it's return value from the *process*
    # block is stored into the main result set.
    #
    # @return [Array<pid, status, data>] An array containing the pid,
    #   status and data returned from the process block.  If wait2() fails nil
    #   is returned.
    def wait(flags=0)
      config.ui.logger.debug { "wait" }
      config.ui.logger.debug { "forks(#{@forks.inspect})" }

      return nil if @forks.count <= 0

      pid, status = (Process.wait2(-1, Process::WUNTRACED) rescue nil)

      if !pid.nil? && !status.nil? && !(fork = @forks.select{ |f| f[:pid] == pid }.first).nil?
        data = nil
        begin
          data = Marshal.load(Zlib::Inflate.inflate(Base64.decode64(fork[:reader].read).to_s))
        rescue Zlib::BufError
          config.ui.logger.fatal { "Encountered Zlib::BufError when reading child pipe." }
        end
        config.ui.logger.debug { "read(#{data.inspect})" }

        data = process_data(data)
        !data.nil? and @results.push(data)

        fork[:reader].close
        fork[:writer].close

        @forks -= [fork]
        return [pid, status, data]
      end
      nil
    end

    # Waits for all forks to finish.
    #
    # @return [Array<Object>] The results from all of the *process* blocks.
    def waitall
      config.ui.logger.debug { "waitall" }
      while @forks.count > 0
        self.wait
      end
      @results
    end

    # Signals all forks.
    #
    # @return [Integer] The number of processes signaled.
    def signal_all(signal="KILL")
      signaled = 0
      if (!@forks.nil? && (@forks.count > 0))
        @forks.each do |fork|
          begin
            Process.kill(signal, fork[:pid])
            signaled += 1
          rescue
            nil
          end
        end
      end
      signaled
    end

    # Count of active forks.
    #
    # @return [Integer] Current number of active forks.
    def count
      config.ui.logger.debug { "count(#{@forks.count})" }
      @forks.count
    end

    # Child PIDs
    #
    # @return [Array<Integer>] An array of child PIDs, if any.
    def pids
      @forks.collect{ |fork| fork[:pid] }
    end


  private

    def process_data(data)
      return data if !(ZTK::Parallel::ExceptionWrapper === data)

      if ((config.raise_exceptions == true) || (ZTK::Parallel::Break === data.exception) || (ZTK::Parallel::Timeout === data.exception))
        config.ui.logger.fatal { "exception(#{data.exception.inspect})" }
        signal_all
        raise data.exception
      end

      config.ui.logger.warn { "exception(#{data.exception.inspect})" }
      return data.exception
    end

  end

end
