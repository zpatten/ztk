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

require "logger"

module ZTK
  class Logger < ::Logger

################################################################################

    SEVERITIES = Severity.constants.inject([]) {|arr,c| arr[Severity.const_get(c)] = c; arr}

################################################################################

    def initialize(*args)
      super(*args)
      set_log_level
    end

################################################################################

    def parse_caller(at)
      if /^(.+?):(\d+)(?::in `(.*)')?/ =~ at
        file = Regexp.last_match[1]
        line = Regexp.last_match[2]
        method = Regexp.last_match[3]
        "#{File.basename(file)}:#{line}:#{method}|"
      else
        ""
      end
    end

################################################################################

    def add(severity, message = nil, progname = nil, &block)
      return if (@level > severity)

      called_by = parse_caller(caller[1])
      msg = (block && block.call)
      (msg.nil? || msg.strip.empty?) and return
      message = [message, progname, msg].delete_if{ |i| i.nil? }.join(": ")
      message = "%19s.%06d|%05d|%5s|%s%s\n" % [Time.now.utc.strftime("%Y-%m-%d|%H:%M:%S"), Time.now.utc.usec, Process.pid, SEVERITIES[severity], called_by, message]

      @logdev.write(message)

      true
    end

################################################################################

    def set_log_level(level=nil)
      defined?(Rails) and (default = (Rails.env.production? ? "INFO" : "DEBUG")) or (default = "INFO")
      log_level = (ENV['LOG_LEVEL'] || level || default)
      self.level = ZTK::Logger.const_get(log_level.to_s.upcase)
    end

################################################################################

  end
end

################################################################################
