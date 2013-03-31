################################################################################
#
#      Author: Zachary Patten <zachary@jovelabs.net>
#   Copyright: Copyright (c) Zachary Patten
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

  # ZTK::Background General Error Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
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
  # *pry output*:
  #
  #     [1] pry(main)> a_callback = Proc.new do |pid|
  #     [1] pry(main)*   puts "Hello from After Callback - PID #{pid}"
  #     [1] pry(main)* end
  #     => #<Proc:0x00000001368a98@(pry):1>
  #     [2] pry(main)>
  #     [3] pry(main)> b_callback = Proc.new do |pid|
  #     [3] pry(main)*   puts "Hello from Before Callback - PID #{pid}"
  #     [3] pry(main)* end
  #     => #<Proc:0x00000001060418@(pry):4>
  #     [4] pry(main)>
  #     [5] pry(main)> background = ZTK::Background.new
  #     => #<ZTK::Background:0x00000001379118
  #      @config=
  #       #<OpenStruct stdout=#<IO:<STDOUT>>, stderr=#<IO:<STDERR>>, stdin=#<IO:<STDIN>>, logger=#<ZTK::Logger filename="/dev/null">>,
  #      @result=nil>
  #     [6] pry(main)> background.config do |config|
  #     [6] pry(main)*   config.before_fork = b_callback
  #     [6] pry(main)*   config.after_fork = a_callback
  #     [6] pry(main)* end
  #     => #<Proc:0x00000001368a98@(pry):1>
  #     [7] pry(main)>
  #     [8] pry(main)> pid = background.process do
  #     [8] pry(main)*   sleep(1)
  #     [8] pry(main)* end
  #     Hello from Before Callback - PID 23564
  #     Hello from After Callback - PID 23564
  #     Hello from After Callback - PID 23578
  #     => 23578
  #     [9] pry(main)> puts pid.inspect
  #     23578
  #     => nil
  #     [10] pry(main)>
  #     [11] pry(main)> background.wait
  #     => [23578, #<Process::Status: pid 23578 exit 0>, 1]
  #     [12] pry(main)> puts background.result.inspect
  #     1
  #     => nil
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Background < ZTK::Base

    # Result Set
    attr_accessor :pid, :result

    # @param [Hash] configuration Configuration options hash.
    #
    def initialize(configuration={})
      super({
      }.merge(configuration))
      config.ui.logger.debug { "config=#{config.send(:table).inspect}" }

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
