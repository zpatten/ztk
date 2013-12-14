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

      # Starts an SCP session.  Can also be used to get the Net::SCP object.
      #
      # Primarily used internally.
      def scp
        @scp ||= self.ssh.scp
        @scp
      end

      # Close our session gracefully.
      def close
        config.ui.logger.debug { "close" }

        if (!@ssh.nil? && !@ssh.closed?)
          config.ui.logger.debug { "SSH object is valid and not closed" }

          begin
            config.ui.logger.debug { "attempting to close" }
            @ssh.close
            config.ui.logger.debug { "closed" }

          rescue Exception => e
            config.ui.logger.fatal { "EXCEPTION: #{e.inspect}" }
          end

        else
          config.ui.logger.debug { "SSH object is NIL!" }
        end

        @ssh = nil
        @sftp = nil

        true
      end

      # The on_retry method we'll use with the RescueRetry class.
      def on_retry(exception)
        config.ui.logger.warn { "ZTK::SSH on_retry triggered!" }

        (close rescue false)
      end

    end

  end
end
