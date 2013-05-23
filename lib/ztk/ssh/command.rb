module ZTK
  class SSH

    # SSH Console Command Helpers
    module Command

      # Builds our SSH console command.
      def console_command
        verbosity = ((ENV['LOG_LEVEL'] == "DEBUG") ? '-vv' : '-q')

        command = Array.new
        # command << [ %(sshpass -p '#{config.password}') ] if config.password
        command << [ %(ssh) ]
        command << [ verbosity ]
        command << [ "-x" ]
        command << [ "-a" ]
        command << [ "-o", "UserKnownHostsFile=/dev/null" ]
        command << [ "-o", "StrictHostKeyChecking=no" ]
        command << [ "-o", "KeepAlive=yes" ]
        command << [ "-o", "ServerAliveInterval=60" ]
        command << [ "-o", %(ProxyCommand="#{proxy_command}") ] if config.proxy_host_name
        command << [ "-i", config.keys ] if config.keys
        command << [ "-p", config.port ] if config.port
        command << "#{config.user}@#{config.host_name}"
        command = command.flatten.compact.join(' ')
        config.ui.logger.debug { "console_command(#{command.inspect})" }
        command
      end

      # Builds our SSH proxy command.
      def proxy_command
        !config.proxy_user and log_and_raise(SSHError, "You must specify an proxy user in order to SSH proxy.")
        !config.proxy_host_name and log_and_raise(SSHError, "You must specify an proxy host_name in order to SSH proxy.")

        verbosity = ((ENV['LOG_LEVEL'] == "DEBUG") ? '-vv' : '-q')

        command = Array.new
        # command << [ %(sshpass -p '#{config.proxy_password}') ] if config.proxy_password
        command << [ %(ssh) ]
        command << [ verbosity ]
        command << [ "-x" ]
        command << [ "-a" ]
        command << [ "-o", "UserKnownHostsFile=/dev/null" ]
        command << [ "-o", "StrictHostKeyChecking=no" ]
        command << [ "-o", "KeepAlive=yes" ]
        command << [ "-o", "ServerAliveInterval=60" ]
        command << [ "-i", config.proxy_keys ] if config.proxy_keys
        command << [ "-p", config.proxy_port ] if config.proxy_port
        command << "#{config.proxy_user}@#{config.proxy_host_name}"
        command << "'/usr/bin/env nc %h %p'"
        command = command.flatten.compact.join(' ')
        config.ui.logger.debug { "proxy_command(#{command.inspect})" }
        command
      end

    end

  end
end
