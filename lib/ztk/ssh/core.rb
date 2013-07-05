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

        if (ssh  && !ssh.closed?)
          ssh.close
        end
        @ssh = nil

        if (!sftp.nil? && !sftp.closed?)
          sftp.close
        end
        @sftp = nil

        true
      end

      # The on_retry method we'll use with the RescueRetry class.
      def on_retry(exception)
        close
      end

    end

  end
end
