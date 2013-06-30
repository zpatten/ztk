module ZTK

  # Command Error Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class CommandError < Error; end

  # Command Execution Class
  #
  # @example We can get a new instance of Command like so:
  #     cmd = ZTK::Command.new
  #
  # @example If we wanted to redirect STDOUT and STDERR to a StringIO we can do this:
  #     std_combo = StringIO.new
  #     ui = ZTK::UI.new(:stdout => std_combo, :stderr => std_combo)
  #     cmd = ZTK::Command.new(:ui => ui, :silence => true)
  #     puts cmd.exec("hostname", :silence => false).inspect
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Command < ZTK::Base
    require 'ostruct'
    require 'timeout'
    require 'socket'

    require 'ztk/command/download'
    require 'ztk/command/exec'
    require 'ztk/command/private'
    require 'ztk/command/upload'

    include ZTK::Command::Download
    include ZTK::Command::Exec
    include ZTK::Command::Upload

    # @param [Hash] configuration Sets the overall default configuration for the
    #   class.  For example, all calls to *exec* against this instance will use
    #   the configuration options specified here by default.  These options can
    #   be overriden on a per call basis as well.
    # @option configuration [Integer] :timeout (600) How long in seconds before
    #   the command will timeout.
    # @option configuration [Boolean] :ignore_exit_status (false) Whether or not
    #   we should ignore the exit status of the the process we spawn.  By
    #   default we do not ignore the exit status and throw an exception if it is
    #   non-zero.
    # @option configuration [Integer] :exit_code (0) The exit code we expect the
    #   process to return.  This is ignore if *ignore_exit_status* is true.
    # @option configuration [Boolean] :silence (false) Whether or not we should
    #   squelch the output of the process.  The output will always go to the
    #   logging device supplied in the ZTK::UI object.  The output is always
    #   available in the return value from the method additionally.
    def initialize(configuration={})
      super({
        :timeout => 600,
        :ignore_exit_status => false,
        :exit_code => 0,
        :silence => false
      }.merge(configuration))

      config.ui.logger.debug { "config=#{config.send(:table).inspect}" }
    end


  private

    include ZTK::Command::Private

  end

end
