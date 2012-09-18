################################################################################
#
#      Author: Zachary Patten <zachary@jovelabs.net>
#   Copyright: Copyright (c) Jove Labs
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

module ZTK

  # ZTK::Command Error Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
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
  #     cmd = ZTK::Command.new(:stdout => std_combo, :stderr => std_combo)
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Command < ZTK::Base

    def initialize(config={})
      super(config)
    end

    # Executes a local command.
    #
    # @param [String] command The command to execute.
    # @param [Hash] options The options hash for executing the command.
    #
    # @return [OpenStruct#output] The output of the command, both STDOUT and
    #   STDERR.
    # @return [OpenStruct#exit] The exit status (i.e. $?).
    #
    # @example Execute a command:
    #
    #   cmd = ZTK::Command.new
    #   puts cmd.exec("hostname -f").inspect
    def exec(command, options={})
      options = OpenStruct.new({ :exit_code => 0, :silence => false }.merge(options))
      log(:debug) { "config(#{@config.inspect})" }
      log(:debug) { "options(#{options.inspect})" }
      log(:debug) { "command(#{command.inspect})" }

      parent_stdout_reader, child_stdout_writer = IO.pipe
      parent_stderr_reader, child_stderr_writer = IO.pipe

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

      Process.waitpid(pid)

      stdout = parent_stdout_reader.read
      stderr = parent_stderr_reader.read
      output = (stdout || '') + (stderr || '')

      @config.stdout.write(stdout) unless options.silence
      @config.stderr.write(stderr) unless options.silence

      parent_stdout_reader.close
      parent_stderr_reader.close

      log(:debug) { "exit_code(#{$?.inspect})" }

      if ($? != options.exit_code)
        message = "exec(#{command.inspect}, #{options.inspect}) failed! [#{$?.inspect}]"
        log(:fatal) { message }
        raise CommandError, message
      end

      OpenStruct.new(:output => output, :exit => $?)
    end

    def upload(*args)
      raise CommandError, "Not Implemented"
    end

    def download(*args)
      raise CommandError, "Not Implemented"
    end

  end

end
