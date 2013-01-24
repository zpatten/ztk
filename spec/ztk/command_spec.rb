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

describe ZTK::Command do

  subject { ZTK::Command.new }

  before(:all) do
    $stdout = File.open("/dev/null", "w")
    $stderr = File.open("/dev/null", "w")
    $stdin = File.open("/dev/null", "r")
  end

  describe "class" do

    it "should be an instance of ZTK::Command" do
      subject.should be_an_instance_of ZTK::Command
    end

    describe "default config" do

      it "should use $stdout as the default" do
        subject.config.stdout.should be_a_kind_of $stdout.class
        subject.config.stdout.should == $stdout
      end

      it "should use $stderr as the default" do
        subject.config.stderr.should be_a_kind_of $stderr.class
        subject.config.stderr.should == $stderr
      end

      it "should use $stdin as the default" do
        subject.config.stdin.should be_a_kind_of $stdin.class
        subject.config.stdin.should == $stdin
      end

      it "should use $logger as the default" do
        subject.config.logger.should be_a_kind_of ZTK::Logger
        subject.config.logger.should == $logger
      end

    end

  end

  it "should be able to execute the command \"hostname -f\"" do
    stdout = StringIO.new
    subject.config do |config|
      config.stdout = stdout
    end
    hostname = %x(hostname -f).chomp
    status = subject.exec("hostname -f")
    status.exit.exitstatus.should == 0
    stdout.rewind
    stdout.read.chomp.should == hostname
  end

  it "should timeout after the period specificed" do
    stdout = StringIO.new
    subject.config do |config|
      config.stdout = stdout
      config.timeout = 3
    end
    hostname = %x(hostname -f).chomp
    lambda { subject.exec("hostname -f ; sleep 10") }.should raise_error ZTK::CommandError
  end

end
