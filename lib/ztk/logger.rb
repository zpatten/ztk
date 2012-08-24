require "logger"

class ZTK::Logger < ::Logger
  SEVERITIES = Severity.constants.inject([]) {|arr,c| arr[Severity.const_get(c)] = c; arr}

  def initialize(filename)
    super(filename)
    set_log_level
  end

  def parse_caller(at)
    if /^(.+?):(\d+)(?::in `(.*)')?/ =~ at
      file = Regexp.last_match[1]
      line = Regexp.last_match[2]
      method = Regexp.last_match[3]
      "#{File.basename(file)}:#{line}:#{method} | "
    else
      ""
    end
  end

  def add(severity, message = nil, progname = nil, &block)
    return if (@level > severity)

    called_by = parse_caller(caller[1])
    msg = (block && block.call)
    return if (msg.nil? || msg.strip.empty?)
    message = [message, progname, msg].delete_if{|i| i == nil}.join(": ")
    message = "%19s.%06d+%05d|%5s|%s%s\n" % [Time.now.utc.strftime("%Y-%m-%d %H:%M:%S"), Time.now.utc.usec, Process.pid, SEVERITIES[severity], called_by, message]

    @logdev.write(message)

    true
  end

  def set_log_level(level=nil)
    defined?(Rails) and (default = (Rails.env.production? ? "INFO" : "DEBUG")) or (default = "INFO")
    log_level = (ENV['LOG_LEVEL'] || level || default)
    self.level = ZTK::Logger.const_get(log_level.to_s.upcase)
  end

end
