################################################################################
#
#      Author: Zachary Patten <zachary@jovelabs.com>
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
  class SSHError < Error; end
  class SSH

################################################################################

    attr_accessor :config

################################################################################

    def initialize(config={})
      @config = OpenStruct.new({
        :stdout => $stdout,
        :stderr => $stderr,
        :stdin => $stdin,
        :logger => $logger,
        :ssh => OpenStruct.new
      }.merge(config))
      @config.stdout.sync = true if @config.stdout.respond_to?(:sync=)
      @config.stderr.sync = true if @config.stderr.respond_to?(:sync=)
      @config.stdin.sync = true if @config.stdin.respond_to?(:sync=)
      @config.logger.sync = true if @config.logger.respond_to?(:sync=)
    end

################################################################################

    def config(&block)
      if block_given?
        yield(@config)
      else
        @config
      end
    end

################################################################################

    def console
      @config.logger and @config.logger.debug { "config(#{@config.ssh.inspect})" }

      command = [ "ssh" ]
      command << [ "-q" ]
      command << [ "-o", "UserKnownHostsFile=/dev/null" ]
      command << [ "-o", "StrictHostKeyChecking=no" ]
      command << [ "-o", "KeepAlive=yes" ]
      command << [ "-o", "ServerAliveInterval=60" ]
      command << [ "-i", @config.ssh.identity_file ] if @config.ssh.identity_file
      command << [ "-o", "ProxyCommand=\"#{proxy_command}\"" ] if @config.ssh.proxy
      command << "#{@config.ssh.user}@#{@config.ssh.host}"
      command = command.flatten.compact.join(" ")
      @config.logger and @config.logger.info { "command(#{command})" }
      Kernel.exec(command)
    end

################################################################################

    def exec(command, options={})
      @ssh ||= ::Net::SSH.start(@config.ssh.host, @config.ssh.user, ssh_options)

      options = { :silence => false }.merge(options)
      silence = options[:silence]
      output = ""

      @config.logger and @config.logger.debug { "config(#{@config.ssh.inspect})" }
      @config.logger and @config.logger.debug { "options(#{options.inspect})" }
      @config.logger and @config.logger.info { "command(#{command})" }
      channel = @ssh.open_channel do |chan|
        @config.logger and @config.logger.debug { "channel opened" }
        chan.exec(command) do |ch, success|
          raise SSHError, "Could not execute '#{command}'." unless success

          ch.on_data do |c, data|
            output += data
            @config.logger and @config.logger.debug { data.chomp.strip }
            @config.stdout.print(data) if !silence
          end

          ch.on_extended_data do |c, type, data|
            output += data
            @config.logger and @config.logger.debug { data.chomp.strip }
            @config.stderr.print(data) if !silence
          end

        end
      end
      channel.wait
      @config.logger and @config.logger.debug { "channel closed" }

      output
    end

################################################################################

    def upload(local, remote)
      @sftp ||= ::Net::SFTP.start(@config.ssh.host, @config.ssh.user, ssh_options)

      @config.logger and @config.logger.debug { "config(#{@config.ssh.inspect})" }
      @config.logger and @config.logger.info { "parameters(#{local},#{remote})" }
      @sftp.upload!(local.to_s, remote.to_s) do |event, uploader, *args|
        case event
        when :open
          @config.logger and @config.logger.info { "upload(#{args[0].local} -> #{args[0].remote})" }
        when :close
          @config.logger and @config.logger.debug { "close(#{args[0].remote})" }
        when :mkdir
          @config.logger and @config.logger.debug { "mkdir(#{args[0]})" }
        when :put
          @config.logger and @config.logger.debug { "put(#{args[0].remote}, size #{args[2].size} bytes, offset #{args[1]})" }
        when :finish
          @config.logger and @config.logger.info { "finish" }
        end
      end
    end

################################################################################

    def download(remote, local)
      @sftp ||= ::Net::SFTP.start(@config.ssh.host, @config.ssh.user, ssh_options)

      @config.logger and @config.logger.debug { "config(#{@config.ssh.inspect})" }
      @config.logger and @config.logger.info { "parameters(#{remote},#{local})" }
      @sftp.download!(remote.to_s, local.to_s) do |event, downloader, *args|
        case event
        when :open
          @config.logger and @config.logger.info { "download(#{args[0].remote} -> #{args[0].local})" }
        when :close
          @config.logger and @config.logger.debug { "close(#{args[0].local})" }
        when :mkdir
          @config.logger and @config.logger.debug { "mkdir(#{args[0]})" }
        when :get
          @config.logger and @config.logger.debug { "get(#{args[0].remote}, size #{args[2].size} bytes, offset #{args[1]})" }
        when :finish
          @config.logger and @config.logger.info { "finish" }
        end
      end
    end


################################################################################
  private
################################################################################

    def proxy_command
      @config.logger and @config.logger.debug { "config(#{@config.ssh.inspect})" }

      if !@config.ssh.identity_file
        message = "You must specify an identity file in order to SSH proxy."
        @config.logger and @config.logger.fatal { message }
        raise SSHError, message
      end

      command = ["ssh"]
      command << [ "-q" ]
      command << [ "-o", "UserKnownHostsFile=/dev/null" ]
      command << [ "-o", "StrictHostKeyChecking=no" ]
      command << [ "-o", "KeepAlive=yes" ]
      command << [ "-o", "ServerAliveInterval=60" ]
      command << [ "-i", @config.ssh[:proxy_identity_file] ] if @config.ssh[:proxy_identity_file]
      command << "#{@config.ssh[:proxy_ssh_user]}@#{@config.ssh[:proxy_host]}"
      command << "nc %h %p"
      command = command.flatten.compact.join(" ")
      @config.logger and @config.logger.debug { "command(#{command})" }
      command
    end

################################################################################

    def ssh_options
      @config.logger and @config.logger.debug { "config(#{@config.ssh.inspect})" }
      options = {}
      options.merge!(:password => @config.ssh.password) if @config.ssh.password
      options.merge!(:keys => @config.ssh.identity_file) if @config.ssh.identity_file
      options.merge!(:timeout => @config.ssh.timeout) if @config.ssh.timeout
      options.merge!(:user_known_hosts_file  => '/dev/null') if !@config.ssh.host_key_verify
      options.merge!(:proxy => ::Net::SSH::Proxy::Command.new(proxy_command)) if @config.ssh.proxy
      @config.logger and @config.logger.debug { "options(#{options.inspect})" }
      options
    end

################################################################################

  end
end

################################################################################
