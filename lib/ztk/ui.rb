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
      @stdout = configuration[:stdout] || $stdout
      @stderr = configuration[:stderr] || $stderr
      @stdin  = configuration[:stdin]  || $stdin
      @logger = configuration[:logger] || ZTK::Logger.new("/dev/null")
    end

  end

end
