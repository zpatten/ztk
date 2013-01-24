################################################################################
#
#      Author: Zachary Patten <zachary@jovelabs.net>
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

require "spec_helper"

describe ZTK::Logger do

  before(:all) do
    ENV["LOG_LEVEL"] = "DEBUG"
    @messages = {
      :debug => "This is a test debug message",
      :info => "This is a test info message",
      :warn => "This is a test warn message",
      :error => "This is a test error message",
      :fatal => "This is a test fatal message"
    }
    @logfile = "/tmp/test.log"
  end

  before(:each) do
    File.exists?(@logfile) && File.delete(@logfile)
  end

  subject { ZTK::Logger.new(@logfile) }

  describe "class" do

    it "should be an instance of ZTK::Logger" do
      subject.should be_an_instance_of ZTK::Logger
    end

    it "should provide access to the raw log file handle" do
      subject.logdev.should be_an_instance_of File
    end

  end

  describe "general logging functionality" do

    it "should accept debug log messages" do
      subject.debug { @messages[:debug] }
      IO.read(@logfile).match(@messages[:debug]).should_not be nil
    end

    it "should accept info log messages" do
      subject.info { @messages[:info] }
      IO.read(@logfile).match(@messages[:info]).should_not be nil
    end

    it "should accept warn log messages" do
      subject.warn { @messages[:warn] }
      IO.read(@logfile).match(@messages[:warn]).should_not be nil
    end

    it "should accept error log messages" do
      subject.error { @messages[:error] }
      IO.read(@logfile).match(@messages[:error]).should_not be nil
    end

    it "should accept fatal log messages" do
      subject.fatal { @messages[:fatal] }
      IO.read(@logfile).match(@messages[:fatal]).should_not be nil
    end

  end

  describe "log message" do

    before(:each) do
      subject.debug { @messages[:debug] }
    end

    it "should contain the date (YYYY-MM-DD)" do
      IO.read(@logfile).match(Time.now.utc.strftime("%Y-%m-%d")).should_not be nil
    end

    it "should contain the time (HH:MM)" do
      IO.read(@logfile).match(Time.now.utc.strftime("%H:%M")).should_not be nil
    end

    it "should contain the current process ID" do
      IO.read(@logfile).match(Process.pid.to_s).should_not be nil
    end

    it "should contain the current log level" do
      IO.read(@logfile).match("DEBUG").should_not be nil
    end

    it "should contain the basename of the file containing the method call" do
      IO.read(@logfile).match(File.basename(__FILE__)).should_not be nil
    end

    it "should contain the log message itself" do
      IO.read(@logfile).match(@messages[:debug]).should_not be nil
    end

  end

  describe "log level" do

    LOG_LEVEL_STEPS = [:debug, :info, :warn, :error, :fatal]

    LOG_LEVEL_STEPS.each do |current_log_level_step|

      it "should allow setting log level to #{current_log_level_step.to_s.upcase} via ENV[\"#{current_log_level_step.to_s.upcase}\"]" do

        ENV["LOG_LEVEL"] = current_log_level_step.to_s.upcase
        File.exists?(@logfile) && File.delete(@logfile)
        subject = ZTK::Logger.new(@logfile)

        LOG_LEVEL_STEPS.each do |log_level_step|
          subject.send(log_level_step) { @messages[log_level_step] }
          if LOG_LEVEL_STEPS.index(log_level_step) >= LOG_LEVEL_STEPS.index(current_log_level_step)
            IO.read(@logfile).match(@messages[log_level_step]).should_not be nil
            IO.read(@logfile).match(log_level_step.to_s.upcase).should_not be nil
          else
            IO.read(@logfile).match(@messages[log_level_step]).should be nil
            IO.read(@logfile).match(log_level_step.to_s.upcase).should be nil
          end
        end

      end

    end
  end

end
