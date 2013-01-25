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

describe ZTK::TCPSocketCheck do

  subject { ZTK::TCPSocketCheck.new }

  before(:all) do
    $stdout = File.open("/dev/null", "w")
    $stderr = File.open("/dev/null", "w")
    $stdin = File.open("/dev/null", "r")
  end

  describe "class" do

    it "should be an instance of ZTK::TCPSocketCheck" do
      subject.should be_an_instance_of ZTK::TCPSocketCheck
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

    describe "config" do

      it "should throw an exception if the host is not specified" do
        subject.config.port = 22
        lambda{ subject.ready? }.should raise_error ZTK::TCPSocketCheckError, "You must supply a host!"
      end

      it "should throw an exception if the port is not specified" do
        subject.config.host = "127.0.0.1"
        lambda{ subject.ready? }.should raise_error ZTK::TCPSocketCheckError, "You must supply a port!"
      end

    end

  end

  describe "behaviour" do

    describe "ready?" do

      describe "read check" do

        it "should return true on a remote read check to github.com:22" do
          subject.config do |config|
            config.host = "github.com"
            config.port = 22
          end
          subject.ready?.should == true
        end

        it "should return false on a remote read check to 127.0.0.1:1" do
          subject.config do |config|
            config.host = "127.0.0.1"
            config.port = 1
          end
          subject.ready?.should == false
        end

      end

      describe "write check" do

        it "should return true on a remote write check to www.google.com:80" do
          subject.config do |config|
            config.host = "www.google.com"
            config.port = 80
            config.data = "GET"
          end
          subject.ready?.should == true
        end

        it "should return false on a remote write check to 127.0.0.1:1" do
          subject.config do |config|
            config.host = "127.0.0.1"
            config.port = 1
            config.data = "GET"
          end
          subject.ready?.should == false
        end

      end

    end

    describe "wait" do

      describe "read check" do

        it "should return false on a read check to 127.0.0.1:0" do
          subject.config do |config|
            config.host = "127.0.0.1"
            config.port = 0
            config.wait = WAIT_SMALL
          end
          subject.wait.should == false
        end

        it "should return true on a read check to github.com:22" do
          subject.config do |config|
            config.host = "github.com"
            config.port = 22
            config.wait = WAIT_SMALL
          end
          subject.wait.should == true
        end

      end

      describe "write check" do

        it "should return false on a write check to 127.0.0.1:1" do
          subject.config do |config|
            config.host = "127.0.0.1"
            config.port = 1
            config.data = "GET"
            config.wait = WAIT_SMALL
          end
          subject.wait.should == false
        end

        it "should return true on a write check to www.google.com:80" do
          subject.config do |config|
            config.host = "www.google.com"
            config.port = 80
            config.data = "GET"
            config.wait = WAIT_SMALL
          end
          subject.wait.should == true
        end

      end

    end

  end

end
