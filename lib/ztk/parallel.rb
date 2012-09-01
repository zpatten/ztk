################################################################################
#
#      Author: Zachary Patten <zachary@jovelabs.com>
#   Copyright: Copyright (c) Jove Labs
#     License: Apache License, Vers::IOn 2.0
#
#   Licensed under the Apache License, Vers::IOn 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDIT::IONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permiss::IOns and
#   limitat::IOns under the License.
#
################################################################################

require "base64"

################################################################################

module ZTK

################################################################################

  class Parallel < ::ZTK::Base

################################################################################

    attr_accessor :results

################################################################################

    def initialize(config={})
      super({
        :max_forks => %x( grep -c processor /proc/cpuinfo ).chomp.to_i,
        :one_shot => false,
        :before_fork => nil,
        :after_fork => nil
      }.merge(config))

      @forks = ::Array.new
      @results = ::Array.new
      ::GC.respond_to?(:copy_on_write_friendly=) and ::GC.copy_on_write_friendly = true
    end

################################################################################

    def process(*args)
      @config.logger.debug{ "FORKS #{@forks.inspect}" }
      pid = nil
      return pid if (@forks.count >= @config.max_forks)

      child_reader, parent_writer = ::IO.pipe
      parent_reader, child_writer = ::IO.pipe

      @config.before_fork and @config.before_fork.call(::Process.pid)
      pid = ::Process.fork do
        @config.after_fork and @config.after_fork.call(::Process.pid)

        parent_writer.close
        parent_reader.close

        if !(data = yield).nil?
          @config.logger.debug{ "WRITE #{data.inspect}" }
          child_writer.write(::Base64.encode64(::Marshal.dump(data)))
        end

        child_reader.close
        child_writer.close
        ::Process.exit!(0)
      end
      @config.after_fork and @config.after_fork.call(::Process.pid)

      child_reader.close
      child_writer.close

      fork = {:reader => parent_reader, :writer => parent_writer, :pid => pid}
      @forks << fork

      pid
    end

################################################################################

    def wait
      @config.logger.debug{ "FORKS #{@forks.inspect}" }
      pid, status = (::Process.wait2(-1, ::Process::WNOHANG) rescue nil)
      if !pid.nil? && !status.nil? && !(fork = @forks.select{ |f| f[:pid] == pid }.first).nil?
        data = (::Marshal.load(::Base64.decode64(fork[:reader].read.to_s)) rescue nil)
        @config.logger.debug{ "READ #{data.inspect}" }
        @results.push(data) if (!data.nil? && !@config.one_shot)
        fork[:reader].close
        fork[:writer].close

        @forks -= [fork]
        return [pid, status, data]
      end
      nil
    end

################################################################################

    def waitall
      data = ::Array.new
      while @forks.count > 0
        data << self.wait
      end
      data
    end

################################################################################

    def count
      @forks.count
    end

################################################################################

  end

################################################################################

end

################################################################################
