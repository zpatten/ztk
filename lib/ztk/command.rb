################################################################################
#
#      Author: Zachary Patten <zachary@jovelabs.com>
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

################################################################################

module ZTK

################################################################################

  class CommandError < Error; end

################################################################################

  class Command < ZTK::Base

################################################################################

    def initialize(config={})
      super(config)
    end

################################################################################

    def exec(command, options={})
      options = OpenStruct.new({ :exit_code => 0, :silence => false }.merge(options))
      @config.logger and @config.logger.debug{ "config(#{@config.inspect})" }
      @config.logger and @config.logger.debug{ "options(#{options.inspect})" }
      @config.logger and @config.logger.debug{ "command(#{command.inspect})" }

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

      @config.stdout.write(parent_stdout_reader.read) unless options.silence
      @config.stderr.write(parent_stderr_reader.read) unless options.silence

      parent_stdout_reader.close
      parent_stderr_reader.close

      @config.logger and @config.logger.debug{ "exit_code(#{$?.inspect})" }

      raise CommandError, "run(#{command.inspect}) failed! [#{$?.inspect}]" if ($? != options.exit_code)

      $?
    end

    def upload(*args)
      raise CommandError, "Not Implemented"
    end

    def download(*args)
      raise CommandError, "Not Implemented"
    end

################################################################################

  end

################################################################################

end

################################################################################
