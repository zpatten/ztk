module ZTK
  class SSH

    # SSH Download Functionality
    module Download

      # Downloads a remote file to the local host.
      #
      # @param [String] remote The remote file/path you with to download from.
      # @param [String] local The local file/path you wish to download to.
      # @param [Hash] options An optional hash of options.
      # @option options [Boolean] :recursive Whether or not to recursively
      #   download files and directories.  By default this looks at the local
      #   target and if it is a directory this is set to *true* otherwise it
      #   will default to *false*.
      #
      # @example Download a file:
      #   $logger = ZTK::Logger.new(STDOUT)
      #   ssh = ZTK::SSH.new
      #   ssh.config do |config|
      #     config.user = ENV["USER"]
      #     config.host_name = "127.0.0.1"
      #   end
      #   local = File.expand_path(File.join(ZTK::Locator.root, "tmp", "id_rsa.pub"))
      #   remote = File.expand_path(File.join(ENV['HOME'], ".ssh", "id_rsa.pub"))
      #   ssh.download(remote, local)
      def download(remote, local, options={})
        options = {:recursive => ::File.directory?(local) }.merge(options)
        options = OpenStruct.new(config.send(:table).merge(options))

        options.ui.logger.debug { "config=#{config.send(:table).inspect}" }
        options.ui.logger.debug { "options=#{options.send(:table).inspect}" }
        options.ui.logger.info { "download(#{remote.inspect}, #{local.inspect})" }

        ZTK::RescueRetry.try(:ui => config.ui, :tries => 3, :on_retry => method(:on_retry)) do
          sftp.download!(remote.to_s, local.to_s, options.send(:table)) do |event, downloader, *args|
            case event
            when :open
              options.ui.logger.debug { "download(#{args[0].remote} -> #{args[0].local})" }
            when :close
              options.ui.logger.debug { "close(#{args[0].local})" }
            when :mkdir
              options.ui.logger.debug { "mkdir(#{args[0]})" }
            when :get
              options.ui.logger.debug { "get(#{args[0].remote}, size #{args[2].size} bytes, offset #{args[1]})" }
              options.on_progress.nil? or options.on_progress.call
            when :finish
              options.ui.logger.debug { "finish" }
            end
          end
        end

        true
      end

    end

  end
end
