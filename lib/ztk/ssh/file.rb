module ZTK
  class SSH

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

        tempfile = Tempfile.new("tempfile")
        ::File.open(tempfile, 'w') do |file|
          yield(file)
        end

        ZTK::RescueRetry.try(:tries => 2, :on_retry => method(:on_retry)) do
          upload(tempfile.path, tempfile.path)

          exec(%(sudo mv -v #{tempfile.path} #{target}), :silence => true)

          exec(%(sudo chown -v #{chown} #{target}), :silence => true) if !chown.nil?
          exec(%(sudo chmod -v #{chmod} #{target}), :silence => true) if !chmod.nil?
        end

        true
      end

    end

  end
end
