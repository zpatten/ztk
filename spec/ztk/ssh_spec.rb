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

describe ZTK::SSH do

  subject { ZTK::SSH.new }

  describe "class" do

    it "should be of kind ZTK::SSH class" do
      subject.should be_an_instance_of ZTK::SSH
    end

    describe "default config" do

      it "should use $stdout as the default STDOUT" do
        subject.config.stdout.should be_a_kind_of $stdout.class
        subject.config.stdout.should == $stdout
      end

      it "should use $stderr as the default STDERR" do
        subject.config.stderr.should be_a_kind_of $stderr.class
        subject.config.stderr.should == $stderr
      end

      it "should use $stdin as the default STDIN" do
        subject.config.stdin.should be_a_kind_of $stdin.class
        subject.config.stdin.should == $stdin
      end

      it "should use $logger as the default logger" do
        subject.config.logger.should be_a_kind_of ZTK::Logger
        subject.config.logger.should == $logger
      end

    end

  end

  # this stuff doesn't work as is under travis-ci
  if !ENV['CI'] && !ENV['TRAVIS']

    it "should be able to connect to 127.0.0.1 as the current user and execute a command (your key must be in ssh-agent)" do
      subject.config do |config|
        config.ssh.user = ENV["USER"]
        config.ssh.host = "127.0.0.1"
      end
      hostname = %x( hostname -f ).chomp
      subject.exec("hostname -f").chomp.should == hostname
    end

    it "should be able to proxy through 127.0.0.1, connecting to 127.0.0.1 as the current user and execute a command (your key must be in ssh-agent)" do
      subject.config do |config|
        config.ssh.user = ENV["USER"]
        config.ssh.host = "127.0.0.1"
        config.ssh.proxy_user = ENV["USER"]
        config.ssh.proxy_host = "127.0.0.1"
      end
      hostname = %x( hostname -f ).chomp
      subject.exec("hostname -f").chomp.should == hostname
    end

  end

end
