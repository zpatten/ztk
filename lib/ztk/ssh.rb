################################################################################
#
#      Author: Zachary Patten <zachary@jovelabs.net>
#   Copyright: Copyright (c) Zachary Patten
#     License: Apache License, Version 2.0
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
################################################################################
require "ostruct"
require "net/ssh"
require "net/ssh/proxy/command"
require "net/sftp"

module ZTK

  # ZTK::SSH Error Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
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
  # @author Zachary Patten <zachary@jovelabs.net>
  class SSH < ZTK::Base
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

    autoload :Bootstrap, 'ztk/ssh/bootstrap'
    autoload :Command,   'ztk/ssh/command'
    autoload :Download,  'ztk/ssh/download'
    autoload :Exec,      'ztk/ssh/exec'
    autoload :File,      'ztk/ssh/file'
    autoload :Upload,    'ztk/ssh/upload'

    include ZTK::SSH::Bootstrap
    include ZTK::SSH::Command
    include ZTK::SSH::Download
    include ZTK::SSH::Exec
    include ZTK::SSH::File
    include ZTK::SSH::Upload

    # @param [Hash] configuration Configuration options hash.
    # @option configuration [String] :host_name Server hostname to connect to.
    # @option configuration [String] :user Username to use for authentication.
    # @option configuration [String, Array<String>] :keys A single or series of
    #   identity files to use for authentication.
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
    def initialize(configuration={})
      super({
        :forward_agent => true,
        :compression => false,
        :user_known_hosts_file => '/dev/null',
        :timeout => 60,
        :ignore_exit_status => false,
        :request_pty => true
      }.merge(configuration))
      config.ui.logger.debug { "config=#{config.send(:table).inspect}" }
    end

    # Starts an SSH session.  Can also be used to get the Net::SSH object.
    #
    # Primarily used internally.
    def ssh
      @ssh ||= Net::SSH.start(config.host_name, config.user, ssh_options)
    end

    # Starts an SFTP session.  Can also be used to get the Net::SFTP object.
    #
    # Primarily used internally.
    def sftp
      @sftp ||= Net::SFTP.start(config.host_name, config.user, ssh_options)
    end

    # Close our session gracefully.
    def close
      config.ui.logger.debug { "close" }
      ssh and !ssh.closed? and ssh.close
    end

    # The on_retry method we'll use with the RescueRetry class.
    def on_retry(exception)
      close
      @ssh = nil
      @sftp = nil
    end

    # Launches an SSH console, replacing the current process with the console
    # process.
    #
    # @example Launch a console:
    #   ssh = ZTK::SSH.new
    #   ssh.config do |config|
    #     config.user = ENV["USER"]
    #     config.host_name = "127.0.0.1"
    #   end
    #   ssh.console
    def console
      config.ui.logger.debug { "config=#{config.send(:table).inspect}" }
      config.ui.logger.info { "console(#{console_command.inspect})" }

      config.ui.logger.fatal { "REPLACING CURRENT PROCESS - GOODBYE!" }
      Kernel.exec(console_command)
    end


  private

    # Builds our SSH options hash.
    def ssh_options
      options = {}

      # These are plainly documented on the Net::SSH config class.
      options.merge!(:encryption => config.encryption) if config.encryption
      options.merge!(:compression => config.compression) if config.compression
      options.merge!(:compression_level => config.compression_level) if config.compression_level
      options.merge!(:timeout => config.timeout) if config.timeout
      options.merge!(:forward_agent => config.forward_agent) if config.forward_agent
      options.merge!(:global_known_hosts_file => config.global_known_hosts_file) if config.global_known_hosts_file
      options.merge!(:auth_methods => config.auth_methods) if config.auth_methods
      options.merge!(:host_key => config.host_key) if config.host_key
      options.merge!(:host_key_alias => config.host_key_alias) if config.host_key_alias
      options.merge!(:host_name => config.host_name) if config.host_name
      options.merge!(:keys => config.keys) if config.keys
      options.merge!(:keys_only => config.keys_only) if config.keys_only
      options.merge!(:hmac => config.hmac) if config.hmac
      options.merge!(:port => config.port) if config.port
      options.merge!(:proxy => Net::SSH::Proxy::Command.new(proxy_command)) if config.proxy_host_name
      options.merge!(:rekey_limit => config.rekey_limit) if config.rekey_limit
      options.merge!(:user => config.user) if config.user
      options.merge!(:user_known_hosts_file => config.user_known_hosts_file) if config.user_known_hosts_file

      # This is not plainly documented on the Net::SSH config class.
      options.merge!(:password => config.password) if config.password

      config.ui.logger.debug { "ssh_options(#{options.inspect})" }
      options
    end

    # Builds a human readable tag about our connection.  Used for internal
    # logging purposes.
    def tag
      tags = Array.new

      if config.proxy_host_name
        proxy_user_host = "#{config.proxy_user}@#{config.proxy_host_name}"
        proxy_port = (config.proxy_port ? ":#{config.proxy_port}" : nil)
        tags << [proxy_user_host, proxy_port].compact.join
        tags << " >>> "
      end

      user_host = "#{config.user}@#{config.host_name}"
      port = (config.port ? ":#{config.port}" : nil)
      tags << [user_host, port].compact.join

      tags.join.strip
    end

    def log_header(what)
      count = 8
      sep = ("=" * count)
      header = [sep, "[ #{what} ]", sep, "[ #{tag} ]", sep, "[ #{what} ]", sep].join
      "#{header}\n"
    end

  end

end
