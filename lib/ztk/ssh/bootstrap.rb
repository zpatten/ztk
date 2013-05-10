module ZTK
  class SSH

    # SSH Bootstrap Functionality
    module Bootstrap
      require 'tempfile'

      # SSH Bootstrap
      #
      # Renders the *content* string into a file on the remote host and proceeds
      # to execute it via */bin/bash*.  Sudo is prefixed by default, but can be
      # disabled.
      #
      # @example Sample Bootstrap, assuming the @ssh variable is an instance of ZTK::SSH connected to a host.
      #   @ssh.bootstrap(IO.read("bootstrap.sh"))
      #
      # @example
      #   @ssh.bootstrap("apt-get -y upgrade")
      #
      # @param [String] content What to render out to the bootstrap file we will
      #   execute.
      # @param [Boolean] use_sudo Whether or not we should prefix *sudo*
      #   on our command.
      def bootstrap(content, use_sudo=true)
        tempfile = Tempfile.new("bootstrap")

        local_tempfile = tempfile.path
        remote_tempfile = ::File.join("/tmp", ::File.basename(local_tempfile))

        ::File.open(local_tempfile, 'w') do |file|
          file.puts(content)
          file.respond_to?(:flush) and file.flush
        end

        self.upload(local_tempfile, remote_tempfile)

        command = Array.new
        command << %(sudo) if (use_sudo == true)
        command << %(/bin/bash)
        command << remote_tempfile
        command = command.join(' ')

        self.exec(command, :silence => true)
      end

    end

  end
end
