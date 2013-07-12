module ZTK
  class SSH

    # SSH Core Functionality
    module Core

      # Starts an SSH session.  Can also be used to get the Net::SSH object.
      #
      # Primarily used internally.
      def ssh
        @ssh ||= Net::SSH.start(config.host_name, config.user, ssh_options)
        @ssh
      end

      # Starts an SFTP session.  Can also be used to get the Net::SFTP object.
      #
      # Primarily used internally.
      def sftp
        @sftp ||= self.ssh.sftp
        @sftp
      end

      # Close our session gracefully.
      def close
        config.ui.logger.debug { "close" }

        if (@ssh && !@ssh.closed?)
          @ssh.close
        end

        @ssh = nil
        @sftp = nil

        true
      end

      # The on_retry method we'll use with the RescueRetry class.
      def on_retry(exception)
        config.ui.logger.warn { "ZTK::SSH on_retry triggered!" }

        close
      end

    end

  end
end
