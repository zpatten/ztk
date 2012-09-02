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

require "socket"

################################################################################

module ZTK

################################################################################

  class TCPSocketCheckError < Error; end

################################################################################

  class TCPSocketCheck < ZTK::Base

################################################################################

    def initialize(config={})
      super({
        :host => nil,
        :port => nil,
        :data => nil,
        :timeout => 5,
        :wait => 60
      }.merge(config))
    end

################################################################################

    def ready?
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

      socket = TCPSocket.new(@config.host, @config.port)

      if @config.data.nil?
        @config.logger and @config.logger.debug { "read(#{@config.host}:#{@config.port})" }
        ((IO.select([socket], nil, nil, @config.timeout) && socket.gets) ? true : false)
      else
        @config.logger and @config.logger.debug { "write(#{@config.host}:#{@config.port}, '#{@config.data}')" }
        ((IO.select(nil, [socket], nil, @config.timeout) && socket.write(@config.data)) ? true : false)
      end

    rescue Errno::ETIMEDOUT, Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
      @config.logger and @config.logger.debug { "#{@config.host}:#{@config.port} - #{e.message}" }
      false
    ensure
      (socket && socket.close)
    end

################################################################################

    def wait
      @config.logger and @config.logger.debug{ "waiting for socket to become available; timeout after #{@config.wait} seconds" }
      Timeout.timeout(@config.wait) do
        until ready?
          @config.logger and @config.logger.debug{ "sleeping 1 second" }
          sleep(1)
        end
      end
      true
    rescue Timeout::Error => e
      @config.logger and @config.logger.warn{ "socket(#{@config.host}:#{@config.port}) timeout!" }
      false
    end

################################################################################

  end

################################################################################

end

################################################################################
