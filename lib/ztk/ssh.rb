################################################################################
#
#      Author: Zachary Patten <zachary@jovelabs.net>
#   Copyright: Copyright (c) Jove Labs
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

    # @param [Hash] configuration Configuration options hash.
    # @option config [String] :host_name Server hostname to connect to.
    # @option config [String] :user Username to use for authentication.
    # @option config [String, Array<String>] :keys A single or series of
    #   identity files to use for authentication.
    # @option config [String] :password Password to use for authentication.
    # @option config [Integer] :timeout SSH connection timeout to use.
    # @option config [Boolean] :compression Weither or not to use compression
    #   for this session.
    # @option config [Integer] :compression_level What level of compression to
    #   use.
    # @option config [String] :proxy_host_name Server hostname to proxy through.
    # @option config [String] :proxy_user Username to use for proxy
    #   authentication.
    # @option config [Boolean] :request_pty Weither or not we should try to
    #   obtain a PTY
    # @option config [String, Array<String>] :proxy_keys A single or series of
    #   identity files to use for authentication with the proxy.
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

    # Launches an SSH console, replacing the current process with the console
    # process.
    #
    # @example Launch a console:
    #   $logger = ZTK::Logger.new(STDOUT)
    #   ssh = ZTK::SSH.new
    #   ssh.config do |config|
    #     config.user = ENV["USER"]
    #     config.host_name = "127.0.0.1"
    #   end
    #   ssh.console
    def console
      config.ui.logger.debug { "config=#{config.send(:table).inspect}" }
      config.ui.logger.info { "console(#{console_command.inspect})" }

      Kernel.exec(console_command)
    end

    # Executes a command on the remote host.
    #
    # @param [String] command The command to execute.
    # @param [Hash] options The options hash for executing the command.
    # @option options [Boolean] :silence Squelch output to STDOUT and STDERR.
    #   If the log level is :debug, STDOUT and STDERR will go to the log file
    #   regardless of this setting.  STDOUT and STDERR are always returned in
    #   the output return value regardless of this setting.
    #
    # @return [OpenStruct#output] The output of the command, both STDOUT and
    #   STDERR.
    # @return [OpenStruct#exit] The exit status (i.e. $?).
    #
    # @example Execute a command:
    #
    #   ssh = ZTK::SSH.new
    #   ssh.config do |config|
    #     config.user = ENV["USER"]
    #     config.host_name = "127.0.0.1"
    #   end
    #   puts ssh.exec("hostname -f").inspect
    def exec(command, options={})
      options = OpenStruct.new({ :exit_code => 0, :silence => false }.merge(config.send(:table)).merge(options))

      options.ui.logger.debug { "config=#{options.send(:table).inspect}" }
      options.ui.logger.debug { "options=#{options.send(:table).inspect}" }
      options.ui.logger.info { "exec(#{command.inspect})" }

      output = ""
      exit_code = -1
      exit_signal = nil
      stdout_header = false
      stderr_header = false

      begin
        Timeout.timeout(options.timeout) do
          ZTK::RescueRetry.try(:tries => 3, :on => EOFError) do
            @ssh = Net::SSH.start(options.host_name, options.user, ssh_options)

            channel = ssh.open_channel do |chan|
              options.ui.logger.debug { "Channel opened." }

              (options.request_pty == true) and chan.request_pty do |ch, success|
                if success
                  options.ui.logger.debug { "PTY obtained." }
                else
                  options.ui.logger.warn { "Could not obtain PTY." }
                end
              end

              direct_log(:info) { log_header("COMMAND") }
              direct_log(:info) { "#{command}\n" }
              direct_log(:info) { log_header("OPENED") }

              chan.exec(command) do |ch, success|
                success or log_and_raise(SSHError, "Could not execute '#{command}'.")

                ch.on_data do |c, data|
                  if !stdout_header
                    direct_log(:info) { log_header("STDOUT") }
                    stdout_header = true
                    stderr_header = false
                  end
                  direct_log(:info) { data }

                  options.ui.stdout.print(data) unless options.silence
                  output += data
                end

                ch.on_extended_data do |c, type, data|
                  if !stderr_header
                    direct_log(:warn) { log_header("STDERR") }
                    stderr_header = true
                    stdout_header = false
                  end
                  direct_log(:warn) { data }

                  options.ui.stderr.print(data) unless options.silence
                  output += data
                end

                ch.on_request("exit-status") do |ch, data|
                  exit_code = data.read_long
                end

                ch.on_request("exit-signal") do |ch, data|
                  exit_signal = data.read_long
                end

                ch.on_open_failed do |c, code, desc|
                  options.ui.logger.fatal { "Open failed! (#{code.inspect} - #{desc.inspect})" }
                end

              end
            end
            channel.wait

            direct_log(:info) { log_header("CLOSED") }
            options.ui.logger.debug { "Channel closed." }
          end
        end

      rescue Timeout::Error => e
        direct_log(:fatal) { log_header("TIMEOUT") }
        log_and_raise(SSHError, "Session timed out after #{options.timeout} seconds!")
      end

      message = [
        "exit_code=#{exit_code}",
        (exit_signal.nil? ? nil : "exit_signal=#{exit_signal} (#{EXIT_SIGNALS[exit_signal]})")
      ].compact.join(", ")

      options.ui.logger.debug { message }

      if !options.ignore_exit_status && (exit_code != options.exit_code)
        log_and_raise(SSHError, message)
      end
      OpenStruct.new(:output => output, :exit_code => exit_code, :exit_signal => exit_signal)
    end

    # Uploads a local file to a remote host.
    #
    # @param [String] local The local file/path you wish to upload from.
    # @param [String] remote The remote file/path you with to upload to.
    #
    # @example Upload a file:
    #   $logger = ZTK::Logger.new(STDOUT)
    #   ssh = ZTK::SSH.new
    #   ssh.config do |config|
    #     config.user = ENV["USER"]
    #     config.host_name = "127.0.0.1"
    #   end
    #   local = File.expand_path(File.join(ENV["HOME"], ".ssh", "id_rsa.pub"))
    #   remote = File.expand_path(File.join("/tmp", "id_rsa.pub"))
    #   ssh.upload(local, remote)
    def upload(local, remote)
      config.ui.logger.debug { "config=#{config.send(:table).inspect}" }
      config.ui.logger.info { "upload(#{local.inspect}, #{remote.inspect})" }

      ZTK::RescueRetry.try(:tries => 3, :on => EOFError) do
        @sftp = Net::SFTP.start(config.host_name, config.user, ssh_options)
        sftp.upload!(local.to_s, remote.to_s) do |event, uploader, *args|
          case event
          when :open
            config.ui.logger.debug { "upload(#{args[0].local} -> #{args[0].remote})" }
          when :close
            config.ui.logger.debug { "close(#{args[0].remote})" }
          when :mkdir
            config.ui.logger.debug { "mkdir(#{args[0]})" }
          when :put
            config.ui.logger.debug { "put(#{args[0].remote}, size #{args[2].size} bytes, offset #{args[1]})" }
          when :finish
            config.ui.logger.debug { "finish" }
          end
        end
      end

      true
    end

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

      ZTK::RescueRetry.try(:tries => 3, :on => EOFError) do
        @sftp = Net::SFTP.start(config.host_name, config.user, ssh_options)
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


  private

    # Builds our SSH console command.
    def console_command
      command = [ "ssh" ]
      command << [ "-q" ]
      command << [ "-A" ]
      command << [ "-o", "UserKnownHostsFile=/dev/null" ]
      command << [ "-o", "StrictHostKeyChecking=no" ]
      command << [ "-o", "KeepAlive=yes" ]
      command << [ "-o", "ServerAliveInterval=60" ]
      command << [ "-i", config.keys ] if config.keys
      command << [ "-p", config.port ] if config.port
      command << [ "-t" ] if config.request_pty
      command << [ "-o", "ProxyCommand=\"#{proxy_command}\"" ] if config.proxy_host_name
      command << "#{config.user}@#{config.host_name}"
      command = command.flatten.compact.join(" ")
      config.ui.logger.debug { "console_command(#{command.inspect})" }
      command
    end

    # Builds our SSH proxy command.
    def proxy_command
      !config.proxy_user and log_and_raise(SSHError, "You must specify an proxy user in order to SSH proxy.")
      !config.proxy_host_name and log_and_raise(SSHError, "You must specify an proxy host_name in order to SSH proxy.")

      command = ["ssh"]
      command << [ "-q" ]
      command << [ "-A" ]
      command << [ "-o", "UserKnownHostsFile=/dev/null" ]
      command << [ "-o", "StrictHostKeyChecking=no" ]
      command << [ "-o", "KeepAlive=yes" ]
      command << [ "-o", "ServerAliveInterval=60" ]
      command << [ "-i", config.proxy_keys ] if config.proxy_keys
      command << [ "-p", config.proxy_port ] if config.proxy_port
      command << [ "-t" ] if config.request_pty
      command << "#{config.proxy_user}@#{config.proxy_host_name}"
      command << "nc %h %p"
      command = command.flatten.compact.join(" ")
      config.ui.logger.debug { "proxy_command(#{command.inspect})" }
      command
    end

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
