module ZTK
  class SSH

    # SSH Command Execution Functionality
    module Exec

      # Executes a command on the remote host.
      #
      # @param [String] command The command to execute.
      # @param [Hash] options The options hash for executing the command.
      # @option options [Integer] :timeout (600) How long in seconds before
      #   the command will timeout.
      # @option options [Boolean] :ignore_exit_status (false) Whether or not
      #   we should ignore the exit status of the the process we spawn.  By
      #   default we do not ignore the exit status and throw an exception if it is
      #   non-zero.
      # @option options [Integer] :exit_code (0) The exit code we expect the
      #   process to return.  This is ignore if *ignore_exit_status* is true.
      # @option options [Boolean] :silence (false) Whether or not we should
      #   squelch the output of the process.  The output will always go to the
      #   logging device supplied in the ZTK::UI object.  The output is always
      #   available in the return value from the method additionally.
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
        options = OpenStruct.new(config.send(:table).merge(options))

        options.ui.logger.debug { "config=#{config.send(:table).inspect}" }
        options.ui.logger.debug { "options=#{options.send(:table).inspect}" }
        options.ui.logger.info { "exec(#{command.inspect})" }

        output = ""
        exit_code = -1
        exit_signal = nil
        stdout_header = false
        stderr_header = false

        begin
          ZTK::RescueRetry.try(:ui => config.ui, :tries => ZTK::SSH::RESCUE_RETRY_ATTEMPTS, :raise => Timeout::Error, :on_retry => method(:on_retry)) do
            Timeout.timeout(options.timeout) do

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
                direct_log(:info) { log_header("OPENED", "-") }

                chan.exec(command) do |ch, success|
                  success or log_and_raise(SSHError, "Could not execute '#{command}'.")

                  ch.on_data do |c, data|
                    if !stdout_header
                      direct_log(:info) { log_header("STDOUT", "-") }
                      stdout_header = true
                      stderr_header = false
                    end
                    direct_log(:info) { data }

                    options.ui.stdout.print(data) unless options.silence
                    output += data

                    options.on_progress.nil? or options.on_progress.call
                  end

                  ch.on_extended_data do |c, type, data|
                    if !stderr_header
                      direct_log(:warn) { log_header("STDERR", "-") }
                      stderr_header = true
                      stdout_header = false
                    end
                    direct_log(:warn) { data }

                    options.ui.stderr.print(data) unless options.silence
                    output += data

                    options.on_progress.nil? or options.on_progress.call
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
