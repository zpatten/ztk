module ZTK
  class SSH

    # SSH Core Functionality
    module Core

      # Starts an SSH session.  Can also be used to get the Net::SSH object.
      #
      # Primarily used internally.
      def ssh
        @ssh ||= Net::SSH.start(config.host_name, config.user, ssh_options)
      end

      # Starts an SFTP session.  Can also be used to get the Net::SFTP object.
      #
      # Primarily used internally.
      def sftp
        @sftp ||= Net::SFTP.start(config.host_name, config.user, ssh_options)
      end

      # Close our session gracefully.
      def close
        config.ui.logger.debug { "close" }
        ssh and !ssh.closed? and ssh.close
      end

      # The on_retry method we'll use with the RescueRetry class.
      def on_retry(exception)
        close
        @ssh = nil
        @sftp = nil
      end

    end

  end
end
