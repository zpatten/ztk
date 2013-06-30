module ZTK
  class SSH

    # SSH Console Functionality
    module Console

      # Launches an SSH console, replacing the current process with the console
      # process.
      #
      # @example Launch a console:
      #   ssh = ZTK::SSH.new
      #   ssh.config do |config|
      #     config.user = ENV["USER"]
      #     config.host_name = "127.0.0.1"
      #   end
      #   ssh.console
      def console
        config.ui.logger.debug { "config=#{config.send(:table).inspect}" }
        config.ui.logger.info { "console(#{console_command.inspect})" }

        config.ui.logger.fatal { "REPLACING CURRENT PROCESS - GOODBYE!" }
        Kernel.exec(console_command)
      end

    end

  end
end
