################################################################################
#
#      Author: Zachary Patten <zachary@jovelabs.net>
#   Copyright: Copyright (c) Jove Labs
#     License: Apache License, VersIOn 2.0
#
#   Licensed under the Apache License, VersIOn 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissIOns and
#   limitatIOns under the License.
#
################################################################################

require "base64"

module ZTK

  # ZTK::UI Error Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class UIError < Error; end

  # ZTK UI Wrapper Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class UI < ZTK::Base

    attr_accessor :stdout, :stderr, :stdin, :logger

    def initialize(configuration={})
      defined?(Rails) and (rails_logger = Rails.logger)
      null_logger = (::ZTK::Logger.new("/dev/null") rescue ::Logger.new("/dev/null"))

      @stdout = (configuration[:stdout] || $stdout || STDOUT)
      @stderr = (configuration[:stderr] || $stderr || STDERR)
      @stdin  = (configuration[:stdin]  || $stdin  || STDIN)
      @logger = (configuration[:logger] || $logger || rails_logger || null_logger)

      (@stdout && @stdout.respond_to?(:sync=)) and @stdout.sync = true
      (@stderr && @stderr.respond_to?(:sync=)) and @stderr.sync = true
      (@stdin  && @stdin.respond_to?(:sync=))  and @stdin.sync  = true
      (@logger && @logger.respond_to?(:sync=)) and @logger.sync = true
    end

  end

end
