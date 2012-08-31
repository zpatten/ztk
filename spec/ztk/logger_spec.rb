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

require "spec_helper"

describe ZTK::Logger do

  before(:all) do
    ENV["LOG_LEVEL"] = "DEBUG"
    @logfile = "/tmp/test.log"
    @messages = {
      :debug => "This is a test debug message",
      :info => "This is a test info message",
      :warn => "This is a test warn message",
      :error => "This is a test error message",
      :fatal => "This is a test fatal message"
    }
    File.exists?(@logfile) && File.delete(@logfile)
  end

  subject { ZTK::Logger.new(@logfile) }

  it "should be of kind ZTK::Logger class" do
    subject.should be_an_instance_of ZTK::Logger
  end

  describe "logging" do

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

  describe "log_level" do

    it "should allow setting log level to DEBUG via ENV[\"LOG_LEVEL\"]" do
      ENV["LOG_LEVEL"] = "DEBUG"

      File.exists?(@logfile) && File.delete(@logfile)
      subject = ZTK::Logger.new(@logfile)

      subject.debug { @messages[:debug] }
      IO.read(@logfile).match(@messages[:debug]).should_not be nil

      subject.info { @messages[:info] }
      IO.read(@logfile).match(@messages[:info]).should_not be nil

      subject.warn { @messages[:warn] }
      IO.read(@logfile).match(@messages[:warn]).should_not be nil

      subject.error { @messages[:error] }
      IO.read(@logfile).match(@messages[:error]).should_not be nil

      subject.fatal { @messages[:fatal] }
      IO.read(@logfile).match(@messages[:fatal]).should_not be nil
    end

    it "should allow setting log level to INFO via ENV[\"LOG_LEVEL\"]" do
      ENV["LOG_LEVEL"] = "INFO"

      File.exists?(@logfile) && File.delete(@logfile)
      subject = ZTK::Logger.new(@logfile)

      subject.debug { @messages[:debug] }
      IO.read(@logfile).match(@messages[:debug]).should be nil

      subject.info { @messages[:info] }
      IO.read(@logfile).match(@messages[:info]).should_not be nil

      subject.warn { @messages[:warn] }
      IO.read(@logfile).match(@messages[:warn]).should_not be nil

      subject.error { @messages[:error] }
      IO.read(@logfile).match(@messages[:error]).should_not be nil

      subject.fatal { @messages[:fatal] }
      IO.read(@logfile).match(@messages[:fatal]).should_not be nil
    end

    it "should allow setting log level to WARN via ENV[\"LOG_LEVEL\"]" do
      ENV["LOG_LEVEL"] = "WARN"

      File.exists?(@logfile) && File.delete(@logfile)
      subject = ZTK::Logger.new(@logfile)

      subject.debug { @messages[:debug] }
      IO.read(@logfile).match(@messages[:debug]).should be nil

      subject.info { @messages[:info] }
      IO.read(@logfile).match(@messages[:info]).should be nil

      subject.warn { @messages[:warn] }
      IO.read(@logfile).match(@messages[:warn]).should_not be nil

      subject.error { @messages[:error] }
      IO.read(@logfile).match(@messages[:error]).should_not be nil

      subject.fatal { @messages[:fatal] }
      IO.read(@logfile).match(@messages[:fatal]).should_not be nil
    end

    it "should allow setting log level to ERROR via ENV[\"LOG_LEVEL\"]" do
      ENV["LOG_LEVEL"] = "ERROR"

      File.exists?(@logfile) && File.delete(@logfile)
      subject = ZTK::Logger.new(@logfile)

      subject.debug { @messages[:debug] }
      IO.read(@logfile).match(@messages[:debug]).should be nil

      subject.info { @messages[:info] }
      IO.read(@logfile).match(@messages[:info]).should be nil

      subject.warn { @messages[:warn] }
      IO.read(@logfile).match(@messages[:warn]).should be nil

      subject.error { @messages[:error] }
      IO.read(@logfile).match(@messages[:error]).should_not be nil

      subject.fatal { @messages[:fatal] }
      IO.read(@logfile).match(@messages[:fatal]).should_not be nil
    end

    it "should allow setting log level to FATAL via ENV[\"LOG_LEVEL\"]" do
      ENV["LOG_LEVEL"] = "FATAL"

      File.exists?(@logfile) && File.delete(@logfile)
      subject = ZTK::Logger.new(@logfile)

      subject.debug { @messages[:debug] }
      IO.read(@logfile).match(@messages[:debug]).should be nil

      subject.info { @messages[:info] }
      IO.read(@logfile).match(@messages[:info]).should be nil

      subject.warn { @messages[:warn] }
      IO.read(@logfile).match(@messages[:warn]).should be nil

      subject.error { @messages[:error] }
      IO.read(@logfile).match(@messages[:error]).should be nil

      subject.fatal { @messages[:fatal] }
      IO.read(@logfile).match(@messages[:fatal]).should_not be nil
    end

  end

end
