################################################################################
#
#      Author: Zachary Patten <zachary@jovelabs.net>
#   Copyright: Copyright (c) Jove Labs
#     License: Apache License, VersIOn 2.0
#
#   Licensed under the Apache License, VersIOn 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissIOns and
#   limitatIOns under the License.
#
################################################################################
require "base64"

module ZTK

  # ZTK::Parallel Error Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
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
  # *example code*:
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
  # *pry output*:
  #
  #     [1] pry(main)> a_callback = Proc.new do |pid|
  #     [1] pry(main)*   puts "Hello from After Callback - PID #{pid}"
  #     [1] pry(main)* end
  #     => #<Proc:0x000000015a8768@(pry):1>
  #     [2] pry(main)>
  #     [3] pry(main)> b_callback = Proc.new do |pid|
  #     [3] pry(main)*   puts "Hello from Before Callback - PID #{pid}"
  #     [3] pry(main)* end
  #     => #<Proc:0x000000012910e8@(pry):4>
  #     [4] pry(main)>
  #     [5] pry(main)> parallel = ZTK::Parallel.new
  #     => #<ZTK::Parallel:0x000000015a9d48
  #      @config=
  #       #<OpenStruct stdout=#<IO:<STDOUT>>, stderr=#<IO:<STDERR>>, stdin=#<IO:<STDIN>>, logger=#<ZTK::Logger filename="/dev/null">, max_forks=12>,
  #      @forks=[],
  #      @results=[]>
  #     [6] pry(main)> parallel.config do |config|
  #     [6] pry(main)*   config.before_fork = b_callback
  #     [6] pry(main)*   config.after_fork = a_callback
  #     [6] pry(main)* end
  #     => #<Proc:0x000000015a8768@(pry):1>
  #     [7] pry(main)>
  #     [8] pry(main)> puts Process.pid.inspect
  #     24761
  #     => nil
  #     [9] pry(main)>
  #     [10] pry(main)> 3.times do |x|
  #     [10] pry(main)*   parallel.process do
  #     [10] pry(main)*     x
  #     [10] pry(main)*   end
  #     [10] pry(main)* end
  #     Hello from Before Callback - PID 24761
  #     Hello from After Callback - PID 24761
  #     Hello from Before Callback - PID 24761
  #     Hello from After Callback - PID 24776
  #     Hello from After Callback - PID 24761
  #     Hello from Before Callback - PID 24761
  #     Hello from After Callback - PID 24779
  #     Hello from After Callback - PID 24761
  #     Hello from After Callback - PID 24782
  #     => 3
  #     [11] pry(main)>
  #     [12] pry(main)> parallel.waitall
  #     => [0, 1, 2]
  #     [13] pry(main)> puts parallel.results.inspect
  #     [0, 1, 2]
  #     => nil
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Parallel < ZTK::Base

    # Default Maximum Number of Forks
    MAX_FORKS = case RUBY_PLATFORM
    when /darwin/ then
      %x( sysctl hw.ncpu ).chomp.split(':').last.strip.to_i
    when /linux/ then
      %x( grep -c processor /proc/cpuinfo ).chomp.strip.to_i
    end

    # Result Set
    attr_accessor :results

    # @param [Hash] configuration Configuration options hash.
    # @option config [Integer] :max_forks Maximum number of forks to use.
    # @option config [Proc] :before_fork (nil) Proc to call before forking.
    # @option config [Proc] :after_fork (nil) Proc to call after forking.
    def initialize(configuration={})
      super({
        :max_forks => MAX_FORKS
      }.merge(configuration))
      config.ui.logger.debug { "config=#{config.send(:table).inspect}" }

      (config.max_forks < 1) and log_and_raise(ParallelError, "max_forks must be equal to or greater than one!")

      @forks = Array.new
      @results = Array.new
      GC.respond_to?(:copy_on_write_friendly=) and GC.copy_on_write_friendly = true
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
        config.after_fork and config.after_fork.call(Process.pid)

        parent_writer.close
        parent_reader.close

        if !(data = block.call).nil?
          config.ui.logger.debug { "write(#{data.inspect})" }
          child_writer.write(Base64.encode64(Marshal.dump(data)))
        end

        child_reader.close
        child_writer.close
        Process.exit!(0)
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
    def wait
      config.ui.logger.debug { "wait" }
      config.ui.logger.debug { "forks(#{@forks.inspect})" }
      pid, status = (Process.wait2(-1) rescue nil)
      if !pid.nil? && !status.nil? && !(fork = @forks.select{ |f| f[:pid] == pid }.first).nil?
        data = (Marshal.load(Base64.decode64(fork[:reader].read.to_s)) rescue nil)
        config.ui.logger.debug { "read(#{data.inspect})" }
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

    # Count of active forks.
    #
    # @return [Integer] Current number of active forks.
    def count
      config.ui.logger.debug { "count(#{@forks.count})" }
      @forks.count
    end

  end

end
