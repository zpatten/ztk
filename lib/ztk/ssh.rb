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

################################################################################

module ZTK

################################################################################

  class SSHError < Error; end

################################################################################

  class SSH < ZTK::Base

################################################################################

    def initialize(config={})
      super({
        :ssh => OpenStruct.new
      }.merge(config))
    end

################################################################################

    def console
      log(:debug) { "config(#{@config.inspect})" }

      command = [ "ssh" ]
      command << [ "-q" ]
      command << [ "-o", "UserKnownHostsFile=/dev/null" ]
      command << [ "-o", "StrictHostKeyChecking=no" ]
      command << [ "-o", "KeepAlive=yes" ]
      command << [ "-o", "ServerAliveInterval=60" ]
      command << [ "-i", @config.identity_file ] if @config.identity_file
      command << [ "-o", "ProxyCommand=\"#{proxy_command}\"" ] if @config.proxy
      command << "#{@config.user}@#{@config.host}"
      command = command.flatten.compact.join(" ")
      log(:info) { "command(#{command.inspect})" }
      Kernel.exec(command)
    end

################################################################################

    def exec(command, options={})
      @ssh ||= Net::SSH.start(@config.host, @config.user, ssh_options)

      options = { :silence => false }.merge(options)
      silence = options[:silence]
      output = ""

      log(:debug) { "config(#{@config.inspect})" }
      log(:debug) { "options(#{options.inspect})" }
      log(:info) { "command(#{command.inspect})" }
      channel = @ssh.open_channel do |chan|
        log(:debug) { "channel opened" }
        chan.exec(command) do |ch, success|
          raise SSHError, "Could not execute '#{command}'." unless success

          ch.on_data do |c, data|
            output += data
            log(:debug) { data.chomp.strip }
            @config.stdout.print(data) if !silence
          end

          ch.on_extended_data do |c, type, data|
            output += data
            log(:debug) { data.chomp.strip }
            @config.stderr.print(data) if !silence
          end

        end
      end
      channel.wait
      log(:debug) { "channel closed" }

      $?
    end

################################################################################

    def upload(local, remote)
      log(:debug) { "upload(#{local.inspect}, #{remote.inspect})" }
      log(:debug) { "config(#{@config.inspect})" }

      @sftp ||= Net::SFTP.start(@config.host, @config.user, ssh_options)
      log(:debug) { "sftp(#{@sftp.inspect})" }

      @sftp.upload!(local.to_s, remote.to_s) do |event, uploader, *args|
        case event
        when :open
          log(:info) { "upload(#{args[0].local} -> #{args[0].remote})" }
        when :close
          log(:debug) { "close(#{args[0].remote})" }
        when :mkdir
          log(:debug) { "mkdir(#{args[0]})" }
        when :put
          log(:debug) { "put(#{args[0].remote}, size #{args[2].size} bytes, offset #{args[1]})" }
        when :finish
          log(:info) { "finish" }
        end
      end

      true
    end

################################################################################

    def download(remote, local)
      log(:debug) { "download(#{remote.inspect}, #{local.inspect})" }
      log(:debug) { "config(#{@config.inspect})" }

      @sftp ||= Net::SFTP.start(@config.host, @config.user, ssh_options)
      log(:debug) { "sftp(#{@sftp.inspect})" }

      @sftp.download!(remote.to_s, local.to_s) do |event, downloader, *args|
        case event
        when :open
          log(:info) { "download(#{args[0].remote} -> #{args[0].local})" }
        when :close
          log(:debug) { "close(#{args[0].local})" }
        when :mkdir
          log(:debug) { "mkdir(#{args[0]})" }
        when :get
          log(:debug) { "get(#{args[0].remote}, size #{args[2].size} bytes, offset #{args[1]})" }
        when :finish
          log(:info) { "finish" }
        end
      end

      true
    end


################################################################################
  private
################################################################################

    def proxy_command
      log(:debug) { "proxy_command" }
      log(:debug) { "config(#{@config.inspect})" }

      if !@config.identity_file
        message = "You must specify an identity file in order to SSH proxy."
        log(:fatal) { message }
        raise SSHError, message
      end

      command = ["ssh"]
      command << [ "-q" ]
      command << [ "-o", "UserKnownHostsFile=/dev/null" ]
      command << [ "-o", "StrictHostKeyChecking=no" ]
      command << [ "-o", "KeepAlive=yes" ]
      command << [ "-o", "ServerAliveInterval=60" ]
      command << [ "-i", @config.proxy_identity_file ] if @config.proxy_identity_file
      command << "#{@config.proxy_user}@#{@config.proxy_host}"
      command << "nc %h %p"
      command = command.flatten.compact.join(" ")
      log(:debug) { "proxy_command(#{command.inspect})" }
      command
    end

################################################################################

    def ssh_options
      log(:debug) { "ssh_options" }
      log(:debug) { "config(#{@config.inspect})" }

      options = {}
      options.merge!(:password => @config.password) if @config.password
      options.merge!(:keys => @config.identity_file) if @config.identity_file
      options.merge!(:timeout => @config.timeout) if @config.timeout
      options.merge!(:user_known_hosts_file  => '/dev/null') if !@config.host_key_verify
      options.merge!(:proxy => Net::SSH::Proxy::Command.new(proxy_command)) if @config.proxy
      log(:debug) { "ssh_options(#{options.inspect})" }
      options
    end

################################################################################

  end

################################################################################

end

################################################################################
