################################################################################
#
#      Author: Zachary Patten <zachary@jovelabs.net>
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

describe ZTK::SSH do

  subject { ZTK::SSH.new }

  describe "class" do

    it "should be an instance of ZTK::SSH" do
      subject.should be_an_instance_of ZTK::SSH
    end

  end

  # this stuff doesn't work as is under travis-ci right now
  describe "direct SSH behaviour" do

    describe "execute" do

      it "should be able to connect to 127.0.0.1 as the current user and execute a command (your key must be in ssh-agent)" do
        subject.config do |config|
          config.ui = $ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
        end

        data = %x(hostname).chomp

        status = subject.exec("hostname")
        status.exit_code.should == 0
        $ui.stdout.rewind
        $ui.stdout.read.chomp.should == data
      end

      it "should timeout after the period specified" do
        subject.config do |config|
          config.ui = $ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
          config.timeout = WAIT_SMALL
        end
        hostname = %x(hostname).chomp
        lambda { subject.exec("hostname ; sleep 10") }.should raise_error ZTK::SSHError
      end

      it "should throw an exception if the exit status is not as expected" do
        subject.config do |config|
          config.ui = $ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
        end
        lambda { subject.exec("/bin/bash -c 'exit 64'") }.should raise_error ZTK::SSHError
      end

      it "should return a instance of an OpenStruct object" do
        subject.config do |config|
          config.ui = $ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
        end
        result = subject.exec(%q{echo "Hello World"})
        result.should be_an_instance_of OpenStruct
      end

      it "should return the exit code" do
        subject.config do |config|
          config.ui = $ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
        end
        data = 64

        result = subject.exec(%Q{/bin/bash -c 'exit #{data}'}, :exit_code => data)
        result.exit_code.should == data
      end

      it "should return the output" do
        subject.config do |config|
          config.ui = $ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
        end
        data = "Hello World @ #{Time.now.utc}"

        result = subject.exec(%Q{echo "#{data}"})
        result.output.match(data).should_not be nil
      end

      it "should allow us to change the expected exit code" do
        subject.config do |config|
          config.ui = $ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
        end
        data = 32
        result = subject.exec(%Q{/bin/bash -c 'exit #{data}'}, :exit_code => data)
      end

      describe "stdout" do

        it "should capture STDOUT (with PTY) and send it to the STDOUT pipe" do
          subject.config do |config|
            config.ui = $ui

            config.user = ENV["USER"]
            config.host_name = "127.0.0.1"
          end
          data = "Hello World @ #{Time.now.utc}"

          subject.exec(%Q{echo "#{data}" -f >&1})

          $ui.stdout.rewind
          $ui.stdout.read.match(data).should_not be nil

          $ui.stderr.rewind
          $ui.stderr.read.match(data).should be nil

          $ui.stdin.rewind
          $ui.stdin.read.match(data).should be nil
        end

        it "should capture STDOUT (without PTY) and send it to the STDOUT pipe" do
          subject.config do |config|
            config.ui = $ui

            config.user = ENV["USER"]
            config.host_name = "127.0.0.1"

            config.request_pty = false
          end
          data = "Hello World @ #{Time.now.utc}"

          subject.exec(%Q{echo "#{data}" -f >&1})

          $ui.stdout.rewind
          $ui.stdout.read.match(data).should_not be nil

          $ui.stderr.rewind
          $ui.stderr.read.match(data).should be nil

          $ui.stdin.rewind
          $ui.stdin.read.match(data).should be nil
        end

      end

      describe "stderr" do

        it "should capture STDERR (with PTY) and send it to the STDOUT pipe" do
          subject.config do |config|
            config.ui = $ui

            config.user = ENV["USER"]
            config.host_name = "127.0.0.1"
          end
          data = "Hello World @ #{Time.now.utc}"

          subject.exec(%Q{echo "#{data}" -f >&2})

          $ui.stdout.rewind
          $ui.stdout.read.match(data).should_not be nil

          $ui.stderr.rewind
          $ui.stderr.read.match(data).should be nil

          $ui.stdin.rewind
          $ui.stdin.read.match(data).should be nil
        end

        it "should capture STDERR (without PTY) and send it to the STDERR pipe" do
          subject.config do |config|
            config.ui = $ui

            config.user = ENV["USER"]
            config.host_name = "127.0.0.1"

            config.request_pty = false
          end
          data = "Hello World @ #{Time.now.utc}"

          subject.exec(%Q{echo "#{data}" -f >&2})

          $ui.stdout.rewind
          $ui.stdout.read.match(data).should be nil

          $ui.stderr.rewind
          $ui.stderr.read.match(data).should_not be nil

          $ui.stdin.rewind
          $ui.stdin.read.match(data).should be nil
        end

      end

    end

    describe "upload" do

      it "should be able to upload a file to 127.0.0.1 as the current user (your key must be in ssh-agent)" do
        subject.config do |config|
          config.ui = $ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
        end

        data = "Hello World @ #{Time.now.utc}"

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

      it "should be able to download a file from 127.0.0.1 as the current user (your key must be in ssh-agent)" do
        subject.config do |config|
          config.ui = $ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
        end

        data = "Hello World @ #{Time.now.utc}"

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

  end if !ENV['CI'] && !ENV['TRAVIS']

  describe "proxy SSH behaviour" do

    describe "execute" do

      it "should be able to proxy through 127.0.0.1, connecting to 127.0.0.1 as the current user and execute a command (your key must be in ssh-agent)" do
        subject.config do |config|
          config.ui = $ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
          config.proxy_user = ENV["USER"]
          config.proxy_host_name = "127.0.0.1"
        end

        data = %x( hostname ).chomp

        status = subject.exec("hostname")
        status.exit_code.should == 0
        $ui.stdout.rewind
        $ui.stdout.read.chomp.should == data
      end

      it "should timeout after the period specified" do
        subject.config do |config|
          config.ui = $ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
          config.proxy_user = ENV["USER"]
          config.proxy_host_name = "127.0.0.1"
          config.timeout = WAIT_SMALL
        end
        hostname = %x(hostname).chomp
        lambda { subject.exec("hostname ; sleep 10") }.should raise_error ZTK::SSHError
      end

      it "should throw an exception if the exit status is not as expected" do
        subject.config do |config|
          config.ui = $ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
          config.proxy_user = ENV["USER"]
          config.proxy_host_name = "127.0.0.1"
        end
        lambda { subject.exec("/bin/bash -c 'exit 64'") }.should raise_error ZTK::SSHError
      end

      it "should return a instance of an OpenStruct object" do
        subject.config do |config|
          config.ui = $ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
          config.proxy_user = ENV["USER"]
          config.proxy_host_name = "127.0.0.1"
        end
        result = subject.exec(%q{echo "Hello World"})
        result.should be_an_instance_of OpenStruct
      end

      it "should return the exit code" do
        subject.config do |config|
          config.ui = $ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
          config.proxy_user = ENV["USER"]
          config.proxy_host_name = "127.0.0.1"
        end
        data = 64

        result = subject.exec(%Q{/bin/bash -c 'exit #{data}'}, :exit_code => data)
        result.exit_code.should == data
      end

      it "should return the output" do
        subject.config do |config|
          config.ui = $ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
          config.proxy_user = ENV["USER"]
          config.proxy_host_name = "127.0.0.1"
        end
        data = "Hello World @ #{Time.now.utc}"

        result = subject.exec(%Q{echo "#{data}"})
        result.output.match(data).should_not be nil
      end

      it "should allow us to change the expected exit code" do
        subject.config do |config|
          config.ui = $ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
          config.proxy_user = ENV["USER"]
          config.proxy_host_name = "127.0.0.1"
        end
        data = 32
        result = subject.exec(%Q{/bin/bash -c 'exit #{data}'}, :exit_code => data)
      end

      describe "stdout" do

        it "should capture STDOUT (with PTY) and send it to the STDOUT pipe" do
          subject.config do |config|
            config.ui = $ui

            config.user = ENV["USER"]
            config.host_name = "127.0.0.1"
            config.proxy_user = ENV["USER"]
            config.proxy_host_name = "127.0.0.1"
          end
          data = "Hello World @ #{Time.now.utc}"

          subject.exec(%Q{echo "#{data}" -f >&1})

          $ui.stdout.rewind
          $ui.stdout.read.match(data).should_not be nil

          $ui.stderr.rewind
          $ui.stderr.read.match(data).should be nil

          $ui.stdin.rewind
          $ui.stdin.read.match(data).should be nil
        end

        it "should capture STDOUT (without PTY) and send it to the STDOUT pipe" do
          subject.config do |config|
            config.ui = $ui

            config.user = ENV["USER"]
            config.host_name = "127.0.0.1"
            config.proxy_user = ENV["USER"]
            config.proxy_host_name = "127.0.0.1"

            config.request_pty = false
          end
          data = "Hello World @ #{Time.now.utc}"

          subject.exec(%Q{echo "#{data}" -f >&1})

          $ui.stdout.rewind
          $ui.stdout.read.match(data).should_not be nil

          $ui.stderr.rewind
          $ui.stderr.read.match(data).should be nil

          $ui.stdin.rewind
          $ui.stdin.read.match(data).should be nil
        end

      end

      describe "stderr" do

        it "should capture STDERR (with PTY) and send it to the STDOUT pipe" do
          subject.config do |config|
            config.ui = $ui

            config.user = ENV["USER"]
            config.host_name = "127.0.0.1"
            config.proxy_user = ENV["USER"]
            config.proxy_host_name = "127.0.0.1"
          end
          data = "Hello World @ #{Time.now.utc}"

          subject.exec(%Q{echo "#{data}" -f >&2})

          $ui.stdout.rewind
          $ui.stdout.read.match(data).should_not be nil

          $ui.stderr.rewind
          $ui.stderr.read.match(data).should be nil

          $ui.stdin.rewind
          $ui.stdin.read.match(data).should be nil
        end

        it "should capture STDERR (without PTY) and send it to the STDERR pipe" do
          subject.config do |config|
            config.ui = $ui

            config.user = ENV["USER"]
            config.host_name = "127.0.0.1"
            config.proxy_user = ENV["USER"]
            config.proxy_host_name = "127.0.0.1"

            config.request_pty = false
          end
          data = "Hello World @ #{Time.now.utc}"

          subject.exec(%Q{echo "#{data}" -f >&2})

          $ui.stdout.rewind
          $ui.stdout.read.match(data).should be nil

          $ui.stderr.rewind
          $ui.stderr.read.match(data).should_not be nil

          $ui.stdin.rewind
          $ui.stdin.read.match(data).should be nil
        end

      end

    end

    describe "upload" do

      it "should be able to upload a file to 127.0.0.1 as the current user (your key must be in ssh-agent)" do
        subject.config do |config|
          config.ui = $ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
          config.proxy_user = ENV["USER"]
          config.proxy_host_name = "127.0.0.1"
        end

        data = "Hello World @ #{Time.now.utc}"

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

      it "should be able to download a file from 127.0.0.1 as the current user (your key must be in ssh-agent)" do
        subject.config do |config|
          config.ui = $ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
          config.proxy_user = ENV["USER"]
          config.proxy_host_name = "127.0.0.1"
        end

        data = "Hello World @ #{Time.now.utc}"

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

  end if !ENV['CI'] && !ENV['TRAVIS']

end
