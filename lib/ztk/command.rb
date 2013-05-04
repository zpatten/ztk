################################################################################
#
#      Author: Zachary Patten <zachary AT jovelabs DOT com>
#   Copyright: Copyright (c) Zachary Patten
#     License: Apache License, Version 2.0
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
################################################################################
require "ostruct"
require "timeout"

module ZTK

  # ZTK::Command Error Class
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class CommandError < Error; end

  # Command Execution Class
  #
  # We can get a new instance of Command like so:
  #
  #     cmd = ZTK::Command.new
  #
  # If we wanted to redirect STDOUT and STDERR to a StringIO we can do this:
  #
  #     std_combo = StringIO.new
  #     ui = ZTK::UI.new(:stdout => std_combo, :stderr => std_combo)
  #     cmd = ZTK::Command.new(:ui => ui)
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Command < ZTK::Base

    def initialize(configuration={})
      super({
        :timeout => 600,
        :ignore_exit_status => false
      }.merge(configuration))
      config.ui.logger.debug { "config=#{config.send(:table).inspect}" }
    end

    # Executes a local command.
    #
    # @param [String] command The command to execute.
    # @param [Hash] options The options hash for executing the command.
    #
    # @return [OpenStruct#output] The output of the command, both STDOUT and
    #   STDERR combined.
    # @return [OpenStruct#exit_code] The exit code of the process.
    #
    # @example Execute a command:
    #
    #   cmd = ZTK::Command.new
    #   puts cmd.exec("hostname").inspect
    #
    def exec(command, options={})
      options = OpenStruct.new({ :exit_code => 0, :silence => false }.merge(config.send(:table)).merge(options))

      options.ui.logger.debug { "config=#{options.send(:table).inspect}" }
      options.ui.logger.debug { "options=#{options.send(:table).inspect}" }
      options.ui.logger.info { "command(#{command.inspect})" }

      if options.replace_current_process
        options.ui.logger.fatal { "REPLACING CURRENT PROCESS - GOODBYE!" }
        Kernel.exec(command)
      end

      output = ""
      exit_code = -1
      stdout_header = false
      stderr_header = false

      parent_stdout_reader, child_stdout_writer = IO.pipe
      parent_stderr_reader, child_stderr_writer = IO.pipe

      start_time = Time.now.utc

      pid = Process.fork do
        parent_stdout_reader.close
        parent_stderr_reader.close

        STDOUT.reopen(child_stdout_writer)
        STDERR.reopen(child_stderr_writer)
        STDIN.reopen("/dev/null")

        child_stdout_writer.close
        child_stderr_writer.close

        Kernel.exec(command)
      end
      child_stdout_writer.close
      child_stderr_writer.close

      reader_writer_key = {parent_stdout_reader => :stdout, parent_stderr_reader => :stderr}
      reader_writer_map = {parent_stdout_reader => options.ui.stdout, parent_stderr_reader => options.ui.stderr}

      direct_log(:info) { log_header("COMMAND") }
      direct_log(:info) { "#{command}\n" }
      direct_log(:info) { log_header("STARTED") }

      begin
        Timeout.timeout(options.timeout) do
          loop do
            pipes = IO.select(reader_writer_map.keys, [], reader_writer_map.keys).first
            pipes.each do |pipe|
              data = pipe.read
              next if (data.nil? || data.empty?)

              case reader_writer_key[pipe]
              when :stdout then
                if !stdout_header
                  direct_log(:info) { log_header("STDOUT") }
                  stdout_header = true
                  stderr_header = false
                end
                reader_writer_map[pipe].write(data) unless options.silence
                direct_log(:info) { data }

              when :stderr then
                if !stderr_header
                  direct_log(:warn) { log_header("STDERR") }
                  stderr_header = true
                  stdout_header = false
                end
                reader_writer_map[pipe].write(data) unless options.silence
                direct_log(:warn) { data }
              end

              output += data
            end
            break if reader_writer_map.keys.all?{ |reader| reader.eof? }
          end
        end
      rescue Timeout::Error => e
        direct_log(:fatal) { log_header("TIMEOUT") }
        log_and_raise(CommandError, "Process timed out after #{options.timeout} seconds!")
      end

      Process.waitpid(pid)
      exit_code = $?.exitstatus
      direct_log(:info) { log_header("STOPPED") }

      parent_stdout_reader.close
      parent_stderr_reader.close

      options.ui.logger.debug { "exit_code(#{exit_code})" }

      if !options.ignore_exit_status && (exit_code != options.exit_code)
        log_and_raise(CommandError, "exec(#{command.inspect}, #{options.inspect}) failed! [#{exit_code}]")
      end
      OpenStruct.new(:command => command, :output => output, :exit_code => exit_code)
    end

    # Not Supported
    # @raise [CommandError] Not Supported
    def upload(*args)
      log_and_raise(CommandError, "Not Supported")
    end

    # Not Supported
    # @raise [CommandError] Not Supported
    def download(*args)
      log_and_raise(CommandError, "Not Supported")
    end


  private

    # Returns a string in the format of "user@hostname" for the current
    #   shell.
    def tag
      @@hostname ||= %x(hostname).chomp
      "#{ENV['USER']}@#{@hostname}"
    end

    # Formats a header suitable for writing to the direct logger when logging
    #   sessions.
    def log_header(what)
      count = 8
      sep = ("=" * count)
      header = [sep, "[ #{what} ]", sep, "[ #{tag} ]", sep, "[ #{what} ]", sep].join
      "#{header}\n"
    end

  end

end
