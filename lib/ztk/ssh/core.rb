module ZTK
  class SSH

    # SSH Core Functionality
    module Core

      # Starts an SSH session.  Can also be used to get the Net::SSH object.
      #
      # Primarily used internally.
      def ssh
        if do_proxy?
          @ssh ||= self.gateway.ssh(config.host_name, config.user, ssh_options)
        else
          @ssh ||= Net::SSH.start(config.host_name, config.user, ssh_options)
        end
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

      # Starts an SSH gateway session.  Can also be used to get the
      # Net::SSH::Gateway object.
      #
      # Primarily used internally.
      def gateway
        @gateway ||= Net::SSH::Gateway.new(config.proxy_host_name, config.proxy_user, gateway_options)
        @gateway
      end

      # Should we run a proxy?
      def do_proxy?
        ((!config.proxy_host_name.nil? && !config.proxy_host_name.empty?) && (!config.proxy_user.nil? && !config.proxy_user.empty?))
      end

      # Attempts to close the SSH session if it is valid.
      def close_ssh
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
      end

      # Attempts to close the gateway session if it is valid.
      def close_gateway
        if (!@gateway.nil?)
          config.ui.logger.debug { "gateway object is valid" }

          begin
            config.ui.logger.debug { "attempting to shutdown" }
            @gateway.shutdown!
            config.ui.logger.debug { "shutdown" }

          rescue Exception => e
            config.ui.logger.fatal { "EXCEPTION: #{e.inspect}" }
          end

        else
          config.ui.logger.debug { "gateway object is NIL!" }
        end
      end

      # Close our session gracefully.
      def close
        config.ui.logger.debug { "close" }

        close_ssh
        close_gateway

        true

      ensure
        @ssh     = nil
        @gateway = nil
        @sftp    = nil
        @scp     = nil
      end

      # The on_retry method we'll use with the RescueRetry class.
      def on_retry(exception)
        config.ui.logger.warn { "ZTK::SSH on_retry triggered!" }

        (close rescue false)
      end

    end

  end
end
