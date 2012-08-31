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

module ZTK
  class Parallel

################################################################################

    attr_accessor :results

################################################################################

    def initialize(options={})
      GC.respond_to?(:copy_on_write_friendly=) and GC.copy_on_write_friendly = true

      options.reverse_merge!(
        :max_forks => `grep -c processor /proc/cpuinfo`.strip.to_i,
        :one_shot => false
      )

      @max_forks = options[:max_forks]
      @one_shot = options[:one_shot]

      @forks = Array.new
      @results = Array.new
    end

################################################################################

    def process
      pid = nil
      return pid if (@forks.count >= @max_forks)

      child_reader, parent_writer = IO.pipe
      parent_reader, child_writer = IO.pipe

      defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
      pid = Process.fork do
        defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection

        parent_writer.close
        parent_reader.close

        if (data = yield).present?
          child_writer.write(Base64.encode64(Marshal.dump(data)))
        end

        child_reader.close
        child_writer.close
        Process.exit!(0)
      end
      defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection

      child_reader.close
      child_writer.close

      fork = {:reader => parent_reader, :writer => parent_writer, :pid => pid}
      @forks << fork

      pid
    end

################################################################################

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

################################################################################

    def waitall
      results = Array.new
      while @forks.count > 0
        results << wait
      end
      results
    end

################################################################################

    def count
      @forks.count
    end

################################################################################

  end
end

################################################################################
