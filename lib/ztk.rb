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

  require 'ztk/base'
  require 'ztk/dsl'

  require 'ztk/ansi'
  require 'ztk/background'
  require 'ztk/benchmark'
  require 'ztk/command'
  require 'ztk/config'
  require 'ztk/locator'
  require 'ztk/logger'
  require 'ztk/parallel'
  require 'ztk/pty'
  require 'ztk/report'
  require 'ztk/rescue_retry'
  require 'ztk/spinner'
  require 'ztk/ssh'
  require 'ztk/tcp_socket_check'
  require 'ztk/template'
  require 'ztk/ui'

end
