module ZTK
  class SSH

    # SSH Download Functionality
    module Download

      # Downloads a remote file to the local host.
      #
      # @param [String] remote The remote file/path you with to download from.
      # @param [String] local The local file/path you wish to download to.
      #
      # @example Download a file:
      #   $logger = ZTK::Logger.new(STDOUT)
      #   ssh = ZTK::SSH.new
      #   ssh.config do |config|
      #     config.user = ENV["USER"]
      #     config.host_name = "127.0.0.1"
      #   end
      #   local = File.expand_path(File.join("/tmp", "id_rsa.pub"))
      #   remote = File.expand_path(File.join(ENV["HOME"], ".ssh", "id_rsa.pub"))
      #   ssh.download(remote, local)
      def download(remote, local)
        config.ui.logger.debug { "config=#{config.send(:table).inspect}" }
        config.ui.logger.info { "download(#{remote.inspect}, #{local.inspect})" }

        ZTK::RescueRetry.try(:tries => 3, :on => EOFError, :on_retry => method(:on_retry)) do
          sftp.download!(remote.to_s, local.to_s) do |event, downloader, *args|
            case event
            when :open
              config.ui.logger.debug { "download(#{args[0].remote} -> #{args[0].local})" }
            when :close
              config.ui.logger.debug { "close(#{args[0].local})" }
            when :mkdir
              config.ui.logger.debug { "mkdir(#{args[0]})" }
            when :get
              config.ui.logger.debug { "get(#{args[0].remote}, size #{args[2].size} bytes, offset #{args[1]})" }
            when :finish
              config.ui.logger.debug { "finish" }
            end
          end
        end

        true
      end

    end

  end
end
