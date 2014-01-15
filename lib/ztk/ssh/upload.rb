module ZTK
  class SSH

    # SSH Upload Functionality
    module Upload

      # Uploads a local file to a remote host.
      #
      # @example Upload a file:
      #   $logger = ZTK::Logger.new(STDOUT)
      #   ssh = ZTK::SSH.new
      #   ssh.config do |config|
      #     config.user = ENV["USER"]
      #     config.host_name = "127.0.0.1"
      #   end
      #   local = File.expand_path(File.join(ENV['HOME'], ".ssh", "id_rsa.pub"))
      #   remote = File.expand_path(File.join(ZTK::Locator.root, "tmp", "id_rsa.pub"))
      #   ssh.upload(local, remote)
      #
      # @param [String] local The local file/path you wish to upload from.
      # @param [String] remote The remote file/path you with to upload to.
      # @param [Hash] options An optional hash of options.
      # @option options [Boolean] :recursive (false) Whether or not to
      #   recursively download files and directories.
      # @option options [Boolean] :use_scp (false) If set to true, the file will
      #   be transfered using SCP instead of SFTP.  The default behaviour is to
      #   use SFTP.  *WARNING: Recursive downloads are handled in differing
      #   manners between SCP and SFTP!*
      # @return [Boolean] True if successful.
      def upload(local, remote, options={})
        options = {
          :recursive => false,
          :use_scp => false
        }.merge(options)
        options = OpenStruct.new(config.send(:table).merge(options))

        options.ui.logger.debug { "config=#{config.send(:table).inspect}" }
        options.ui.logger.debug { "options=#{options.send(:table).inspect}" }
        config.ui.logger.info { "upload(#{local.inspect}, #{remote.inspect})" }

        ZTK::RescueRetry.try(:ui => config.ui, :tries => ZTK::SSH::RESCUE_RETRY_ATTEMPTS, :on_retry => method(:on_retry)) do
          if (options.use_scp == false)
            sftp.upload!(local.to_s, remote.to_s) do |event, uploader, *args|
              case event
              when :open
                options.ui.logger.debug { "upload(#{args[0].local} -> #{args[0].remote})" }
                options.on_progress.nil? or options.on_progress.call(:open, args)
              when :close
                options.ui.logger.debug { "close(#{args[0].remote})" }
                options.on_progress.nil? or options.on_progress.call(:close, args)
              when :mkdir
                options.ui.logger.debug { "mkdir(#{args[0]})" }
                options.on_progress.nil? or options.on_progress.call(:mkdir, args)
              when :put
                options.ui.logger.debug { "put(#{args[0].remote}, size #{args[2].size} bytes, offset #{args[1]})" }
                options.on_progress.nil? or options.on_progress.call(:put, args)
              when :finish
                options.ui.logger.debug { "finish" }
                options.on_progress.nil? or options.on_progress.call(:finish, args)
              end
            end
          else
            opened = false
            args = []

            scp.upload!(local.to_s, remote.to_s, options.send(:table)) do |ch, name, sent, total|
              args = [ OpenStruct.new(:size => total, :local => name, :remote => name), sent, '' ]

              opened or (options.on_progress.nil? or options.on_progress.call(:open, args) and (opened = true))

              options.ui.logger.debug { "put(#{args[0].remote}, sent #{args[1]}, total #{args[0].size})" }
              options.on_progress.nil? or options.on_progress.call(:put, args)
            end

            options.ui.logger.debug { "finish" }
            options.on_progress.nil? or options.on_progress.call(:finish, args)
          end
        end

        true
      end

    end

  end
end
