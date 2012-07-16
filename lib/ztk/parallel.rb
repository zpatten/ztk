class ZTK::Parallel
  attr_accessor :results

  def initialize(options={})
    GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)

    options.reverse_merge!(
      :max_forks => `grep -c processor /proc/cpuinfo`.strip.to_i,
      :one_shot => false
    )

    @max_forks = options[:max_forks]
    @one_shot = options[:one_shot]

    @forks = Array.new
    @results = Array.new
  end

  def process
    pid = nil
    return pid if (@forks.count >= @max_forks)

    child_reader, parent_writer = IO.pipe
    parent_reader, child_writer = IO.pipe

    ActiveRecord::Base.connection.disconnect!
    pid = Process.fork do
      ActiveRecord::Base.establish_connection

      parent_writer.close
      parent_reader.close

      if (data = yield).present?
        child_writer.write(Base64.encode64(Marshal.dump(data)))
      end

      child_reader.close
      child_writer.close
      Process.exit!(0)
    end
    ActiveRecord::Base.establish_connection

    child_reader.close
    child_writer.close

    fork = {:reader => parent_reader, :writer => parent_writer, :pid => pid}
    @forks << fork

    pid
  end

  def wait
    pid, status = (Process.wait2(-1, Process::WNOHANG) rescue nil)
    if pid.present? && status.present?
      if (fork = @forks.select{ |f| f[:pid] == pid }.first).present?
        data = (Marshal.load(Base64.decode64(fork[:reader].read.to_s)) rescue nil)
        @results.push(data) if (data.present? && !@one_shot)

        fork[:reader].close
        fork[:writer].close

        @forks -= [fork]
        return [pid, status, data]
      end
    end
    nil
  end

  def waitall
    results = Array.new
    while @forks.count > 0
      results << wait
    end
    results
  end

  def count
    @forks.count
  end

end
