################################################################################
#
#      Author: Zachary Patten <zachary AT jovelabs DOT com>
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

require "spec_helper"

LOG_LEVEL_STEPS = [:debug, :info, :warn, :error, :fatal]

describe ZTK::Logger do

  let(:messages) do
    {
      :debug => "This is a test debug message",
      :info => "This is a test info message",
      :warn => "This is a test warn message",
      :error => "This is a test error message",
      :fatal => "This is a test fatal message"
    }
  end

  let(:logfile) { File.join(File.dirname(Tempfile.new), "logger-#{Time.now.to_i}") }

  subject { ZTK::Logger.new(logfile) }

  before(:each) do
    ENV["LOG_LEVEL"] = "DEBUG"
  end

  after(:each) do
    File.exists?(logfile) && File.delete(logfile)
  end

  describe "class" do

    it "should be an instance of ZTK::Logger" do
      expect(subject).to be_an_instance_of ZTK::Logger
    end

  end

  describe "general logging functionality" do

    it "should accept debug log messages" do
      subject.debug { messages[:debug] }
      expect(IO.read(logfile)).to match(messages[:debug])
    end

    it "should accept info log messages" do
      subject.info { messages[:info] }
      expect(IO.read(logfile)).to match(messages[:info])
    end

    it "should accept warn log messages" do
      subject.warn { messages[:warn] }
      expect(IO.read(logfile)).to match(messages[:warn])
    end

    it "should accept error log messages" do
      subject.error { messages[:error] }
      expect(IO.read(logfile)).to match(messages[:error])
    end

    it "should accept fatal log messages" do
      subject.fatal { messages[:fatal] }
      expect(IO.read(logfile)).to match(messages[:fatal])
    end

  end

  describe "speciality logging functionality" do

    it "should allow writing directly to the log device" do
      data = "Hello World"
      subject << data
      expect(IO.read(logfile)).to match(data)
    end

    it "should allow us to echo log statements to STDOUT" do
      data = "Hello World"
      stdout = StringIO.new
      $stdout = stdout
      subject.loggers = [ ::Logger.new($stdout) ]

      subject.debug { data }

      stdout.rewind
      expect(stdout.read).to match(data)
    end

  end

  describe "log message" do

    before(:each) do
      subject.debug { messages[:debug] }
    end

    it "should contain the date (YYYY-MM-DD)" do
      expect(IO.read(logfile)).to match(Time.now.utc.strftime("%Y-%m-%d"))
    end

    it "should contain the time (HH:MM)" do
      expect(IO.read(logfile)).to match(Time.now.utc.strftime("%H:%M"))
    end

    it "should contain the current process ID" do
      expect(IO.read(logfile)).to match(Process.pid.to_s)
    end

    it "should contain the current log level" do
      expect(IO.read(logfile)).to match("DEBUG")
    end

    it "should contain the basename of the file containing the method call" do
      expect(IO.read(logfile)).to match(File.basename(__FILE__))
    end

    it "should contain the log message itself" do
      expect(IO.read(logfile)).to match(messages[:debug])
    end

  end

  describe "log level" do

    LOG_LEVEL_STEPS.each do |current_log_level_step|

      it "should allow setting log level to #{current_log_level_step.to_s.upcase} via ENV[\"#{current_log_level_step.to_s.upcase}\"]" do

        ENV["LOG_LEVEL"] = current_log_level_step.to_s.upcase

        LOG_LEVEL_STEPS.each do |log_level_step|
          subject.send(log_level_step) { messages[log_level_step] }

          logdata = IO.read(logfile)

          if LOG_LEVEL_STEPS.index(log_level_step) >= LOG_LEVEL_STEPS.index(current_log_level_step)
            expect(logdata).to match(messages[log_level_step])
            expect(logdata).to match(log_level_step.to_s.upcase)
          else
            expect(logdata).not_to match(messages[log_level_step])
            expect(logdata).not_to match(log_level_step.to_s.upcase)
          end
        end

      end

    end
  end

end
