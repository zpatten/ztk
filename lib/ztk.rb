require 'ztk/version'

# Main ZTK module
#
# ZTK is a general purpose utility library.  It definately has devops activities
# in mind.  It provides several classes that ease SSH and SFTP, templating,
# and a myraid of other activities.
#
# @author Zachary Patten <zachary AT jovelabs DOT com>
module ZTK

  # ZTK error class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Error < StandardError; end

  autoload :Base, "ztk/base"
  autoload :DSL, "ztk/dsl"

  autoload :ANSI, "ztk/ansi"
  autoload :Background, "ztk/background"
  autoload :Benchmark, "ztk/benchmark"
  autoload :Command, "ztk/command"
  autoload :Config, "ztk/config"
  autoload :Locator, "ztk/locator"
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
