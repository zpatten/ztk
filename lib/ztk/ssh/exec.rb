################################################################################
#
#      Author: Zachary Patten <zachary@jovelabs.net>
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
module ZTK
  class SSH

    module Exec

      # Executes a command on the remote host.
      #
      # @param [String] command The command to execute.
      # @param [Hash] options The options hash for executing the command.
      # @option options [Boolean] :silence Squelch output to STDOUT and STDERR.
      #   If the log level is :debug, STDOUT and STDERR will go to the log file
      #   regardless of this setting.  STDOUT and STDERR are always returned in
      #   the output return value regardless of this setting.
      #
      # @return [OpenStruct#output] The output of the command, both STDOUT and
      #   STDERR.
      # @return [OpenStruct#exit] The exit status (i.e. $?).
      #
      # @example Execute a command:
      #
      #   ssh = ZTK::SSH.new
      #   ssh.config do |config|
      #     config.user = ENV["USER"]
      #     config.host_name = "127.0.0.1"
      #   end
      #   puts ssh.exec("hostname").inspect
      def exec(command, options={})
        options = OpenStruct.new({ :exit_code => 0, :silence => false }.merge(config.send(:table)).merge(options))

        options.ui.logger.debug { "config=#{options.send(:table).inspect}" }
        options.ui.logger.debug { "options=#{options.send(:table).inspect}" }
        options.ui.logger.info { "exec(#{command.inspect})" }

        output = ""
        exit_code = -1
        exit_signal = nil
        stdout_header = false
        stderr_header = false

        begin
          Timeout.timeout(options.timeout) do
            ZTK::RescueRetry.try(:tries => 3, :on => EOFError, :on_retry => method(:on_retry)) do

              channel = ssh.open_channel do |chan|
                options.ui.logger.debug { "Channel opened." }

                (options.request_pty == true) and chan.request_pty do |ch, success|
                  if success
                    options.ui.logger.debug { "PTY obtained." }
                  else
                    options.ui.logger.warn { "Could not obtain PTY." }
                  end
                end

                direct_log(:info) { log_header("COMMAND") }
                direct_log(:info) { "#{command}\n" }
                direct_log(:info) { log_header("OPENED") }

                chan.exec(command) do |ch, success|
                  success or log_and_raise(SSHError, "Could not execute '#{command}'.")

                  ch.on_data do |c, data|
                    if !stdout_header
                      direct_log(:info) { log_header("STDOUT") }
                      stdout_header = true
                      stderr_header = false
                    end
                    direct_log(:info) { data }

                    options.ui.stdout.print(data) unless options.silence
                    output += data
                  end

                  ch.on_extended_data do |c, type, data|
                    if !stderr_header
                      direct_log(:warn) { log_header("STDERR") }
                      stderr_header = true
                      stdout_header = false
                    end
                    direct_log(:warn) { data }

                    options.ui.stderr.print(data) unless options.silence
                    output += data
                  end

                  ch.on_request("exit-status") do |c, data|
                    exit_code = data.read_long
                  end

                  ch.on_request("exit-signal") do |c, data|
                    exit_signal = data.read_long
                  end

                  ch.on_open_failed do |c, code, desc|
                    options.ui.logger.fatal { "Open failed! (#{code.inspect} - #{desc.inspect})" }
                  end

                end
              end
              channel.wait

              direct_log(:info) { log_header("CLOSED") }
              options.ui.logger.debug { "Channel closed." }
            end
          end

        rescue Timeout::Error => e
          direct_log(:fatal) { log_header("TIMEOUT") }
          log_and_raise(SSHError, "Session timed out after #{options.timeout} seconds!")
        end

        message = [
          "exit_code=#{exit_code}",
          (exit_signal.nil? ? nil : "exit_signal=#{exit_signal} (#{EXIT_SIGNALS[exit_signal]})")
        ].compact.join(", ")

        options.ui.logger.debug { message }

        if !options.ignore_exit_status && (exit_code != options.exit_code)
          log_and_raise(SSHError, message)
        end
        OpenStruct.new(:command => command, :output => output, :exit_code => exit_code, :exit_signal => exit_signal)
      end

    end

  end
end
