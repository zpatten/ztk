################################################################################
#
#      Author: Zachary Patten <zachary AT jovelabs DOT net>
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
module ZTK
  class SSH

    module Command

      # Builds our SSH console command.
      def console_command
        verbosity = ((ENV['LOG_LEVEL'] == "DEBUG") ? '-vv' : '-q')

        command = [ "/usr/bin/env ssh" ]
        command << [ verbosity ]
        command << [ "-x" ]
        command << [ "-a" ]
        command << [ "-o", "UserKnownHostsFile=/dev/null" ]
        command << [ "-o", "StrictHostKeyChecking=no" ]
        command << [ "-o", "KeepAlive=yes" ]
        command << [ "-o", "ServerAliveInterval=60" ]
        command << [ "-o", %(ProxyCommand="#{proxy_command}") ] if config.proxy_host_name
        command << [ "-i", config.keys ] if config.keys
        command << [ "-p", config.port ] if config.port
        command << "#{config.user}@#{config.host_name}"
        command = command.flatten.compact.join(' ')
        config.ui.logger.debug { "console_command(#{command.inspect})" }
        command
      end

      # Builds our SSH proxy command.
      def proxy_command
        !config.proxy_user and log_and_raise(SSHError, "You must specify an proxy user in order to SSH proxy.")
        !config.proxy_host_name and log_and_raise(SSHError, "You must specify an proxy host_name in order to SSH proxy.")

        verbosity = ((ENV['LOG_LEVEL'] == "DEBUG") ? '-vv' : '-q')

        command = ["/usr/bin/env ssh"]
        command << [ verbosity ]
        command << [ "-x" ]
        command << [ "-a" ]
        command << [ "-o", "UserKnownHostsFile=/dev/null" ]
        command << [ "-o", "StrictHostKeyChecking=no" ]
        command << [ "-o", "KeepAlive=yes" ]
        command << [ "-o", "ServerAliveInterval=60" ]
        command << [ "-i", config.proxy_keys ] if config.proxy_keys
        command << [ "-p", config.proxy_port ] if config.proxy_port
        command << "#{config.proxy_user}@#{config.proxy_host_name}"
        command << "'/usr/bin/env nc %h %p'"
        command = command.flatten.compact.join(' ')
        config.ui.logger.debug { "proxy_command(#{command.inspect})" }
        command
      end

    end

  end
end
