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

describe ZTK::SSH do

  subject { ZTK::SSH.new }

  before(:all) do
    $stdout = File.open("/dev/null", "w")
    $stderr = File.open("/dev/null", "w")
    $stdin = File.open("/dev/null", "r")
  end

  describe "class" do

    it "should be an instance of ZTK::SSH" do
      subject.should be_an_instance_of ZTK::SSH
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

    # this stuff doesn't work as is under travis-ci
    if !ENV['CI'] && !ENV['TRAVIS']

      describe "direct behaviour" do

        describe "execute" do

          it "should be able to connect to 127.0.0.1 as the current user and execute a command (your key must be in ssh-agent)" do
            stdout, stderr = StringIO.new, StringIO.new
            subject.config do |config|
              config.stdout = stdout
              config.stderr = stderr
              config.user = ENV["USER"]
              config.host_name = "127.0.0.1"
            end

            data = %x(hostname -f).chomp

            status = subject.exec("hostname -f")
            status.exit.exitstatus.should == 0
            stdout.rewind
            stdout.read.chomp.should == data
          end

        end

        describe "upload" do

          it "should be able to upload a file to 127.0.0.1 as the current user and execute a command (your key must be in ssh-agent)" do
            stdout, stderr = StringIO.new, StringIO.new
            subject.config do |config|
              config.stdout = stdout
              config.stderr = stderr
              config.user = ENV["USER"]
              config.host_name = "127.0.0.1"
            end

            data = "Hello World"

            remote_file = File.join("/tmp", "ssh-upload-remote")
            File.exists?(remote_file) && File.delete(remote_file)

            local_file = File.join("/tmp", "ssh-upload-local")
            IO.write(local_file, data)

            File.exists?(remote_file).should == false
            subject.upload(local_file, remote_file)
            File.exists?(remote_file).should == true

            File.exists?(remote_file) && File.delete(remote_file)
            File.exists?(local_file) && File.delete(local_file)
          end

        end

        describe "download" do

          it "should be able to download a file from 127.0.0.1 as the current user and execute a command (your key must be in ssh-agent)" do
            stdout, stderr = StringIO.new, StringIO.new
            subject.config do |config|
              config.stdout = stdout
              config.stderr = stderr
              config.user = ENV["USER"]
              config.host_name = "127.0.0.1"
            end

            data = "Hello World"

            local_file = File.join("/tmp", "ssh-download-local")
            File.exists?(local_file) && File.delete(local_file)

            remote_file = File.join("/tmp", "ssh-download-remote")
            IO.write(remote_file, data)

            File.exists?(local_file).should == false
            subject.download(remote_file, local_file)
            File.exists?(local_file).should == true

            File.exists?(local_file) && File.delete(local_file)
            File.exists?(remote_file) && File.delete(remote_file)
          end

        end

      end

      describe "proxy behaviour" do

        describe "execute" do

          it "should be able to proxy through 127.0.0.1, connecting to 127.0.0.1 as the current user and execute a command (your key must be in ssh-agent)" do
            stdout, stderr = StringIO.new, StringIO.new
            subject.config do |config|
              config.stdout = stdout
              config.stderr = stderr
              config.user = ENV["USER"]
              config.host_name = "127.0.0.1"
              config.proxy_user = ENV["USER"]
              config.proxy_host_name = "127.0.0.1"
            end

            data = %x( hostname -f ).chomp

            status = subject.exec("hostname -f")
            status.exit.exitstatus.should == 0
            stdout.rewind
            stdout.read.chomp.should == data
          end

        end

        describe "upload" do

          it "should be able to upload a file to 127.0.0.1 as the current user and execute a command (your key must be in ssh-agent)" do
            stdout, stderr = StringIO.new, StringIO.new
            subject.config do |config|
              config.stdout = stdout
              config.stderr = stderr
              config.user = ENV["USER"]
              config.host_name = "127.0.0.1"
              config.proxy_user = ENV["USER"]
              config.proxy_host_name = "127.0.0.1"
            end

            data = "Hello World"

            remote_file = File.join("/tmp", "ssh-upload-remote")
            File.exists?(remote_file) && File.delete(remote_file)

            local_file = File.join("/tmp", "ssh-upload-local")
            IO.write(local_file, data)

            File.exists?(remote_file).should == false
            subject.upload(local_file, remote_file)
            File.exists?(remote_file).should == true

            File.exists?(remote_file) && File.delete(remote_file)
            File.exists?(local_file) && File.delete(local_file)
          end

        end

        describe "download" do

          it "should be able to download a file from 127.0.0.1 as the current user and execute a command (your key must be in ssh-agent)" do
            stdout, stderr = StringIO.new, StringIO.new
            subject.config do |config|
              config.stdout = stdout
              config.stderr = stderr
              config.user = ENV["USER"]
              config.host_name = "127.0.0.1"
              config.proxy_user = ENV["USER"]
              config.proxy_host_name = "127.0.0.1"
            end

            data = "Hello World"

            local_file = File.join("/tmp", "ssh-download-local")
            File.exists?(local_file) && File.delete(local_file)

            remote_file = File.join("/tmp", "ssh-download-remote")
            IO.write(remote_file, data)

            File.exists?(local_file).should == false
            subject.download(remote_file, local_file)
            File.exists?(local_file).should == true

            File.exists?(local_file) && File.delete(local_file)
            File.exists?(remote_file) && File.delete(remote_file)
          end

        end

      end

    end

  end

end
