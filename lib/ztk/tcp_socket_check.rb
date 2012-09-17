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

require 'socket'
require 'timeout'

module ZTK

  # ZTK::TCPSocketCheck error class
  #
  # @author Zachary Patten <zachary@jovelabs.com>
  class TCPSocketCheckError < Error; end

  # TCP Socket Checking Class
  #
  # Given a host and port we want to check, we can do something like this:
  #     sc = ZTK::TCPSocketCheck.new(:host => "www.github.com", :port => 22)
  #
  # Then if we want to check if this host is responding on the specified port:
  #     sc.ready? and puts("They are there!")
  #
  # This works well for protocols that spew forth some data right away for use
  # to read.  However, with certain protocols, such as HTTP, we need to send
  # some data first before we get a response.
  #
  # Given we want to check a host and port that requires some giving before we
  # can take:
  #     sc = ZTK::TCPSocketCheck.new(:host => "www.google.com", :port => 80, :data => "GET")
  #
  # Then if we want to check if this host is responding on the specified port:
  #     sc.ready? and puts("They are there!")
  # The ready? methods timeout is bound to the configuration option *timeout*.
  #
  # If we are waiting for a service to come online, we can do this:
  #     sc.wait and puts("They are there!")
  # The wait methods timeout is bound to the configuration option *wait*.
  #
  # @author Zachary Patten <zachary@jovelabs.com>
  class TCPSocketCheck < ZTK::Base

    # @param [Hash] config Configuration options hash.
    # @option config [String] :host Host to connect to.
    # @option config [Integer, String] :port Port to connect to.
    # @option config [String] :data Data to send to host to provoke a response.
    # @option config [Integer] :timeout (5) Set the IO select timeout.
    # @option config [Integer] :wait (60) Set the amount of time before the wait
    #   method call will timeout.
    def initialize(config={})
      super({
        :timeout => 5,
        :wait => 60
      }.merge(config))
    end

    # Check to see if socket on the host and port specified is ready.  This
    # method will timeout and return false after the amount of seconds specified
    # in *config.timeout* has passed if the socket has not become ready.
    #
    # @return [Boolean] Returns true or false depending on weither the socket
    #   is ready or not.
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

    # Wait for the socket on the host and port specified to become ready.  This
    # method will timeout and return false after the amount of seconds specified
    # in *config.wait* has passed if the socket has not become ready.
    #
    # @return [Boolean] Returns true or false depending on weither the socket
    #   became ready or not.
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

  end

end
