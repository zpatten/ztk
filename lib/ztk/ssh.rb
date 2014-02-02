module ZTK

  # SSH Error Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class SSHError < Error; end

  # SSH Multi-function Class
  #
  # We can get a new instance of SSH like so:
  #
  #     ssh = ZTK::SSH.new
  #
  # If we wanted to redirect STDOUT and STDERR to a StringIO we can do this:
  #
  #     std_combo = StringIO.new
  #     ui = ZTK::UI.new(:stdout => std_combo, :stderr => std_combo)
  #     ssh = ZTK::SSH.new(:ui => ui)
  #
  # If you want to specify SSH options you can:
  #
  #     keys = File.expand_path(File.join(ENV['HOME'], '.ssh', 'id_rsa'))
  #     ssh = ZTK::SSH.new(:host_name => '127.0.0.1', :user => ENV['USER'], :keys => keys)
  #
  # = Configuration Examples:
  #
  # To proxy through another host, for example SSH to 192.168.1.1 through 192.168.0.1:
  #
  #     ssh.config do |config|
  #       config.user = ENV['USER']
  #       config.host_name = '192.168.1.1'
  #       config.proxy_user = ENV['USER']
  #       config.proxy_host_name = '192.168.0.1'
  #     end
  #
  # Specify an identity file:
  #
  #     ssh.config do |config|
  #       config.keys = File.expand_path(File.join(ENV['HOME'], '.ssh', 'id_rsa'))
  #       config.proxy_keys = File.expand_path(File.join(ENV['HOME'], '.ssh', 'id_rsa'))
  #     end
  #
  # Specify a timeout:
  #
  #     ssh.config do |config|
  #       config.timeout = 30
  #     end
  #
  # Specify a password:
  #
  #     ssh.config do |config|
  #       config.password = 'p@$$w0rd'
  #     end
  #
  # Check host keys, the default is false (off):
  #
  #     ssh.config do |config|
  #       config.host_key_verify = true
  #     end
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class SSH < ZTK::Base
    require 'ostruct'
    require 'tempfile'
    require 'net/ssh'
    require 'net/ssh/gateway'
    require 'net/ssh/proxy/command'
    require 'net/sftp'
    require 'net/scp'

    # Exit Signal Mappings
    EXIT_SIGNALS = {
      1 => "SIGHUP",
      2 => "SIGINT",
      3 => "SIGQUIT",
      4 => "SIGILL",
      5 => "SIGTRAP",
      6 => "SIGABRT",
      7 => "SIGBUS",
      8 => "SIGFPE",
      9 => "SIGKILL",
      10 => "SIGUSR1",
      11 => "SIGSEGV",
      12 => "SIGUSR2",
      13 => "SIGPIPE",
      14 => "SIGALRM",
      15 => "SIGTERM",
      # 16 unused?
      17 => "SIGCHLD",
      18 => "SIGCONT",
      19 => "SIGSTOP",
      20 => "SIGTSTP",
      21 => "SIGTTIN",
      22 => "SIGTTOU",
      23 => "SIGURG",
      24 => "SIGXCPU",
      25 => "SIGXFSZ",
      26 => "SIGVTALRM",
      27 => "SIGPROF"
    }

    RESCUE_RETRY_ATTEMPTS = 5

    require 'ztk/ssh/bootstrap'
    require 'ztk/ssh/command'
    require 'ztk/ssh/console'
    require 'ztk/ssh/core'
    require 'ztk/ssh/download'
    require 'ztk/ssh/exec'
    require 'ztk/ssh/file'
    require 'ztk/ssh/private'
    require 'ztk/ssh/upload'

    include ZTK::SSH::Bootstrap
    include ZTK::SSH::Command
    include ZTK::SSH::Console
    include ZTK::SSH::Core
    include ZTK::SSH::Download
    include ZTK::SSH::Exec
    include ZTK::SSH::File
    include ZTK::SSH::Upload

    # @param [Hash] configuration Configuration options hash.
    # @option configuration [String] :host_name Server hostname to connect to.
    # @option configuration [String] :user Username to use for authentication.
    # @option configuration [String, Array<String>] :keys A single or series of
    #   identity files to use for authentication.  You can also supply keys as
    #   String blobs which will be rendered to temporary files automatically.
    # @option configuration [String] :password Password to use for authentication.
    # @option configuration [Integer] :timeout (60) SSH connection timeout in
    #   seconds to use.
    # @option configuration [Boolean] :compression (false) Whether or not to use
    #   compression for this session.
    # @option configuration [Integer] :compression_level What level of
    #   compression to use.
    # @option configuration [String] :proxy_host_name Server hostname to proxy
    #   through.
    # @option configuration [String] :proxy_user Username to use for proxy
    #   authentication.
    # @option configuration [Boolean] :request_pty (true) Whether or not we
    #   should try to obtain a PTY
    # @option configuration [Boolean] :ignore_exit_status (false) Whether or not
    #   we should throw an exception if the exit status is not kosher.
    # @option configuration [Boolean] :forward_agent (true) Whether or not to
    #   enable SSH agent forwarding.
    # @option configuration [String, Array<String>] :proxy_keys A single or
    #   series of identity files to use for authentication with the proxy.
    # @option options [Boolean] :ignore_exit_status (false) Whether or not
    #   we should ignore the exit status of the the process we spawn.  By
    #   default we do not ignore the exit status and throw an exception if it is
    #   non-zero.
    # @option options [Integer] :exit_code (0) The exit code we expect the
    #   process to return.  This is ignore if *ignore_exit_status* is true.
    # @option options [Boolean] :silence (false) Whether or not we should
    #   squelch the output of the process.  The output will always go to the
    #   logging device supplied in the ZTK::UI object.  The output is always
    #   available in the return value from the method additionally.
    def initialize(configuration={})
      super({
        :forward_agent => true,
        :compression => false,
        :user_known_hosts_file => '/dev/null',
        :timeout => 60,
        :ignore_exit_status => false,
        :request_pty => true,
        :exit_code => 0,
        :silence => false
      }, configuration)
    end


  private

    include ZTK::SSH::Private

  end

end
