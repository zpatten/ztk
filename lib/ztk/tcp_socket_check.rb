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

module ZTK

################################################################################

  class TCPSocketCheckError < Error; end

################################################################################

  class TCPSocketCheck < Base

################################################################################

    def initialize(config={})
      super({
        :host => nil,
        :port => nil,
        :data => nil
      }.merge(config))

      if @config.host.nil?
        message = "You must supply a host!"
        @config.logger and @config.logger.fatal { message }
        raise TCPSocketCheckError, message
      end

      if @config.port.nil?
        message = "You must supply a port!"
        @config.logger and @config.logger.fatal { message }
        raise TCPSocketCheckError, message
      end
    end

################################################################################

    def ready?
      socket = ::TCPSocket.new(@config.host, @config.port)

      if @config.data.nil?
        @config.logger and @config.logger.debug { "read(#{@config.host}:#{@config.port})" }
        ((::IO.select([socket], nil, nil, 5) && socket.gets) ? true : false)
      else
        @config.logger and @config.logger.debug { "write(#{@config.host}:#{@config.port}, '#{@config.data}')" }
        ((::IO.select(nil, [socket], nil, 5) && socket.write(@config.data)) ? true : false)
      end

    rescue Errno::ETIMEDOUT, Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
      @config.logger and @config.logger.debug { "#{@config.host}:#{@config.port} - #{e.message}" }
      false
    ensure
      (socket && socket.close)
    end

################################################################################

    def wait
      begin
        success = ready?
        sleep(1)
      end until success
    end

################################################################################

  end

################################################################################

end

################################################################################
