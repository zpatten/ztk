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

module ZTK

  # @author Zachary Patten <zachary@jovelabs.com>
  class TCPSocketCheckError < Error; end

  # @author Zachary Patten <zachary@jovelabs.com>
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
        log(:fatal) { message }
        raise TCPSocketCheckError, message
      end

      if @config.port.nil?
        message = "You must supply a port!"
        log(:fatal) { message }
        raise TCPSocketCheckError, message
      end

      socket = TCPSocket.new(@config.host, @config.port)

      if @config.data.nil?
        log(:debug) { "read(#{@config.host}:#{@config.port})" }
        ((IO.select([socket], nil, nil, @config.timeout) && socket.gets) ? true : false)
      else
        log(:debug) { "write(#{@config.host}:#{@config.port}, '#{@config.data}')" }
        ((IO.select(nil, [socket], nil, @config.timeout) && socket.write(@config.data)) ? true : false)
      end

    rescue Errno::ETIMEDOUT, Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
      log(:debug) { "#{@config.host}:#{@config.port} - #{e.message}" }
      false
    ensure
      (socket && socket.close)
    end

################################################################################

    def wait
      log(:debug) { "waiting for socket to become available; timeout after #{@config.wait} seconds" }
      Timeout.timeout(@config.wait) do
        until ready?
          log(:debug) { "sleeping 1 second" }
          sleep(1)
        end
      end
      true
    rescue Timeout::Error => e
      log(:warn) { "socket(#{@config.host}:#{@config.port}) timeout!" }
      false
    end

################################################################################

  end

################################################################################

end

################################################################################
