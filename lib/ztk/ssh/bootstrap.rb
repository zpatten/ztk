module ZTK
  class SSH

    module Bootstrap
      require 'tempfile'

      def bootstrap(content, use_sudo=true)
        tempfile = Tempfile.new("bootstrap")

        ::File.open(tempfile, 'w') do |file|
          file.puts(content)
          file.respond_to?(:flush) and file.flush
        end

        self.upload(tempfile.path, tempfile.path)

        command = Array.new
        command << %(sudo) if (use_sudo == true)
        command << %(/bin/bash)
        command << tempfile.path
        command = command.join(' ')

        self.exec(command, :silence => true)
      end

    end

  end
end
