################################################################################
#
#      Author: Zachary Patten <zachary@jovelabs.net>
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

require "ztk/version"

# Main ZTK module
#
# ZTK is a general purpose utility library.  It definately has devops activities
# in mind.  It provides several classes that ease SSH and SFTP, templating,
# and a myraid of other activities.
#
# @author Zachary Patten <zachary@jovelabs.net>
module ZTK

  # ZTK error class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Error < StandardError; end

  autoload :Base, "ztk/base"
  autoload :DSL, "ztk/dsl"

  autoload :Background, "ztk/background"
  autoload :Benchmark, "ztk/benchmark"
  autoload :Command, "ztk/command"
  autoload :Config, "ztk/config"
  autoload :Logger, "ztk/logger"
  autoload :Parallel, "ztk/parallel"
  autoload :PTY, "ztk/pty"
  autoload :Report, "ztk/report"
  autoload :RescueRetry, "ztk/rescue_retry"
  autoload :Spinner, "ztk/spinner"
  autoload :SSH, "ztk/ssh"
  autoload :TCPSocketCheck, "ztk/tcp_socket_check"
  autoload :Template, "ztk/template"
  autoload :UI, "ztk/ui"

end
