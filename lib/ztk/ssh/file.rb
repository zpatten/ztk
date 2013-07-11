module ZTK
  class SSH

    # SSH Remote File Functionality
    module File
      require 'tempfile'

      # Opens a temporary local file, yielding this to the supplied block.  Once
      # the block returns the temporary file is uploaded to the remote host and
      # installed as the supplied target.
      #
      # If the optional 'chown' or 'chmod' options are supplied then their
      # respective actions will be taken on the target file on the remote host.
      #
      # @param [Hash] options The options hash.
      # @option options [String] :target The target file on the remote host.
      # @option options [String] :chown A user:group representation of who
      #   to change ownership of the target file to (i.e. 'root:root').
      # @option options [String] :chmod An octal file mode which to set the
      #   target file to (i.e. '0755').
      # @return [Boolean] Returns true if successful.
      def file(options={}, &block)
        target = options[:target]
        chown  = options[:chown]
        chmod  = options[:chmod]

        target.nil? and raise SSHError, "You must supply a target file!"
        !block_given? and raise SSHError, "You must supply a block!"

        file_tempfile = Tempfile.new("file")
        remote_tempfile = ::File.join("", "tmp", ::File.basename(file_tempfile.path.dup))
        file_tempfile.close!

        local_tempfile  = Tempfile.new("tempfile-local")

        !block.nil? and block.call(local_tempfile)
        local_tempfile.respond_to?(:flush) and local_tempfile.flush

        ZTK::RescueRetry.try(:ui => config.ui, :tries => 3, :on_retry => method(:on_retry)) do
          self.upload(local_tempfile.path, remote_tempfile)

          self.exec(%(sudo mv -fv #{remote_tempfile} #{target}), :silence => true)

          chown.nil? or self.exec(%(sudo chown -v #{chown} #{target}), :silence => true)
          chmod.nil? or self.exec(%(sudo chmod -v #{chmod} #{target}), :silence => true)
        end

        local_tempfile.close!

        true
      end

    end

  end
end
