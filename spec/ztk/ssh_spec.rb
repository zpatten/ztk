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

describe ZTK::SSH do

  before(:each) do
    @ui = ZTK::UI.new(
      :stdout => StringIO.new,
      :stderr => StringIO.new,
      :stdin => StringIO.new
    )
  end

  subject { ZTK::SSH.new(:ui => @ui) }

  describe "class" do

    it "should be an instance of ZTK::SSH" do
      expect(subject).to be_an_instance_of ZTK::SSH
    end

  end

  # this stuff doesn't work as is under travis-ci right now
  describe "direct SSH behaviour" do

    describe "execute" do

      it "should be able to connect to 127.0.0.1 as the current user and execute a command (your key must be in ssh-agent)" do
        subject.config do |config|
          config.ui = @ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
        end

        data = %x(hostname).chomp

        status = subject.exec("hostname")
        status.exit_code.should == 0
        @ui.stdout.rewind
        @ui.stdout.read.chomp.should == data

        expect(subject.close).to be true
      end

      it "should timeout after the period specified" do
        subject.config do |config|
          config.ui = @ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
          config.timeout = WAIT_SMALL
        end
        hostname = %x(hostname).chomp
        lambda { subject.exec("hostname ; sleep 10") }.should raise_error ZTK::SSHError

        expect(subject.close).to be true
      end

      it "should throw an exception if the exit status is not as expected" do
        subject.config do |config|
          config.ui = @ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
        end
        lambda { subject.exec("/bin/bash -c 'exit 64'") }.should raise_error ZTK::SSHError

        expect(subject.close).to be true
      end

      it "should return a instance of an OpenStruct object" do
        subject.config do |config|
          config.ui = @ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
        end
        result = subject.exec(%q{echo "Hello World"})
        result.should be_an_instance_of OpenStruct

        expect(subject.close).to be true
      end

      it "should return the exit code" do
        subject.config do |config|
          config.ui = @ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
        end
        data = 64

        result = subject.exec(%Q{/bin/bash -c 'exit #{data}'}, :exit_code => data)
        result.exit_code.should == data

        expect(subject.close).to be true
      end

      it "should return the output" do
        subject.config do |config|
          config.ui = @ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
        end
        data = "Hello World @ #{Time.now.utc}"

        result = subject.exec(%Q{echo "#{data}"})
        result.output.match(data).should_not be nil

        expect(subject.close).to be true
      end

      it "should allow us to change the expected exit code" do
        subject.config do |config|
          config.ui = @ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
        end
        data = 32
        result = subject.exec(%Q{/bin/bash -c 'exit #{data}'}, :exit_code => data)

        expect(subject.close).to be true
      end

      it "should allow us to execute a bootstrap script" do
        subject.config do |config|
          config.ui = @ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
        end
        data = "Hello World @ #{Time.now.utc}"

        result = subject.bootstrap(<<-EOBOOTSTRAP)
echo "#{data}" >&1
EOBOOTSTRAP

        expect(result.output).to match(/#{data}/)

        expect(subject.close).to be true
      end

      it "should allow us to write a file" do
        subject.config do |config|
          config.ui = @ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
        end
        data = "Hello World @ #{Time.now.utc}"
        test_filename = File.join("", "tmp", "test_file.txt")

        subject.file(:target => test_filename) do |f|
          f.write(data)
        end

        result = subject.exec(%Q{cat #{test_filename}})

        expect(result.output).to match(/#{data}/)

        expect(subject.close).to be true
      end

      describe "stdout" do

        it "should capture STDOUT (with PTY) and send it to the STDOUT pipe" do
          subject.config do |config|
            config.ui = @ui

            config.user = ENV["USER"]
            config.host_name = "127.0.0.1"
          end
          data = "Hello World @ #{Time.now.utc}"

          subject.exec(%Q{echo "#{data}" >&1})

          @ui.stdout.rewind
          expect(@ui.stdout.read).to match(/#{data}/)

          @ui.stderr.rewind
          expect(@ui.stderr.read).to be_empty

          @ui.stdin.rewind
          expect(@ui.stdin.read).to be_empty

          expect(subject.close).to be true
        end

        it "should capture STDOUT (without PTY) and send it to the STDOUT pipe" do
          subject.config do |config|
            config.ui = @ui

            config.user = ENV["USER"]
            config.host_name = "127.0.0.1"

            config.request_pty = false
          end
          data = "Hello World @ #{Time.now.utc}"

          subject.exec(%Q{echo "#{data}" >&1})

          @ui.stdout.rewind
          expect(@ui.stdout.read).to match(/#{data}/)

          @ui.stderr.rewind
          expect(@ui.stderr.read).to be_empty

          @ui.stdin.rewind
          expect(@ui.stdin.read).to be_empty

          expect(subject.close).to be true
        end

      end

      describe "stderr" do

        it "should capture STDERR (with PTY) and send it to the STDOUT pipe" do
          subject.config do |config|
            config.ui = @ui

            config.user = ENV["USER"]
            config.host_name = "127.0.0.1"
          end
          data = "Hello World @ #{Time.now.utc}"

          subject.exec(%Q{echo "#{data}" >&2})

          @ui.stdout.rewind
          expect(@ui.stdout.read).to match(/#{data}/)

          @ui.stderr.rewind
          expect(@ui.stderr.read).to be_empty

          @ui.stdin.rewind
          expect(@ui.stdin.read).to be_empty

          expect(subject.close).to be true
        end

        it "should capture STDERR (without PTY) and send it to the STDERR pipe" do
          subject.config do |config|
            config.ui = @ui

            config.user = ENV["USER"]
            config.host_name = "127.0.0.1"

            config.request_pty = false
          end
          data = "Hello World @ #{Time.now.utc}"

          subject.exec(%Q{echo "#{data}" >&2})

          @ui.stdout.rewind
          expect(@ui.stdout.read).to be_empty

          @ui.stderr.rewind
          expect(@ui.stderr.read).to match(/#{data}/)

          @ui.stdin.rewind
          expect(@ui.stdin.read).to be_empty

          expect(subject.close).to be true
        end

      end

    end

    describe "upload" do

      [true, false].each do |use_scp|
        it "should be able to upload a file to 127.0.0.1 as the current user using #{use_scp ? 'scp' : 'sftp'} (your key must be in ssh-agent)" do
          subject.config do |config|
            config.ui = @ui

            config.user = ENV["USER"]
            config.host_name = "127.0.0.1"
          end

          data = "Hello World @ #{Time.now.utc}"

          remote_temp = Tempfile.new('remote')
          remote_file = File.join(ZTK::Locator.root, "tmp", File.basename(remote_temp.path.dup))
          remote_temp.close
          File.exists?(remote_file) && File.delete(remote_file)

          local_temp = Tempfile.new('local')
          local_file = File.join(ZTK::Locator.root, "tmp", File.basename(local_temp.path.dup))
          local_temp.close
          if RUBY_VERSION < "1.9.3"
            File.open(local_file, 'w') do |file|
              file.puts(data)
            end
          else
            IO.write(local_file, data)
          end

          File.exists?(remote_file).should == false
          subject.upload(local_file, remote_file, :use_scp => use_scp)
          File.exists?(remote_file).should == true

          File.exists?(remote_file) && File.delete(remote_file)
          File.exists?(local_file) && File.delete(local_file)

          expect(subject.close).to be true
        end
      end

    end

    describe "download" do

      [true, false].each do |use_scp|
        it "should be able to download a file from 127.0.0.1 as the current user using #{use_scp ? 'scp' : 'sftp'} (your key must be in ssh-agent)" do
          subject.config do |config|
            config.ui = @ui

            config.user = ENV["USER"]
            config.host_name = "127.0.0.1"
          end

          data = "Hello World @ #{Time.now.utc}"

          local_temp = Tempfile.new('local')
          local_file = File.join(ZTK::Locator.root, "tmp", File.basename(local_temp.path.dup))
          local_temp.close
          File.exists?(local_file) && File.delete(local_file)

          remote_temp = Tempfile.new('remote')
          remote_file = File.join(ZTK::Locator.root, "tmp", File.basename(remote_temp.path.dup))
          remote_temp.close
          if RUBY_VERSION < "1.9.3"
            File.open(remote_file, 'w') do |file|
              file.puts(data)
            end
          else
            IO.write(remote_file, data)
          end

          File.exists?(local_file).should == false
          subject.download(remote_file, local_file, :use_scp => use_scp)
          File.exists?(local_file).should == true

          File.exists?(local_file) && File.delete(local_file)
          File.exists?(remote_file) && File.delete(remote_file)

          expect(subject.close).to be true
        end
      end

    end

  end

  describe "proxy SSH behaviour" do

    describe "execute" do

      it "should be able to proxy through 127.0.0.1, connecting to 127.0.0.1 as the current user and execute a command (your key must be in ssh-agent)" do
        subject.config do |config|
          config.ui = @ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
          config.proxy_user = ENV["USER"]
          config.proxy_host_name = "127.0.0.1"
        end

        data = %x( hostname ).chomp

        status = subject.exec("hostname")
        status.exit_code.should == 0
        @ui.stdout.rewind
        @ui.stdout.read.chomp.should == data

        expect(subject.close).to be true
      end

      it "should timeout after the period specified" do
        subject.config do |config|
          config.ui = @ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
          config.proxy_user = ENV["USER"]
          config.proxy_host_name = "127.0.0.1"
          config.timeout = WAIT_SMALL
        end
        hostname = %x(hostname).chomp
        lambda { subject.exec("hostname ; sleep 10") }.should raise_error ZTK::SSHError

        expect(subject.close).to be true
      end

      it "should throw an exception if the exit status is not as expected" do
        subject.config do |config|
          config.ui = @ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
          config.proxy_user = ENV["USER"]
          config.proxy_host_name = "127.0.0.1"
        end
        lambda { subject.exec("/bin/bash -c 'exit 64'") }.should raise_error ZTK::SSHError

        expect(subject.close).to be true
      end

      it "should return a instance of an OpenStruct object" do
        subject.config do |config|
          config.ui = @ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
          config.proxy_user = ENV["USER"]
          config.proxy_host_name = "127.0.0.1"
        end
        result = subject.exec(%q{echo "Hello World"})
        result.should be_an_instance_of OpenStruct

        expect(subject.close).to be true
      end

      it "should return the exit code" do
        subject.config do |config|
          config.ui = @ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
          config.proxy_user = ENV["USER"]
          config.proxy_host_name = "127.0.0.1"
        end
        data = 64

        result = subject.exec(%Q{/bin/bash -c 'exit #{data}'}, :exit_code => data)
        result.exit_code.should == data

        expect(subject.close).to be true
      end

      it "should return the output" do
        subject.config do |config|
          config.ui = @ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
          config.proxy_user = ENV["USER"]
          config.proxy_host_name = "127.0.0.1"
        end
        data = "Hello World @ #{Time.now.utc}"

        result = subject.exec(%Q{echo "#{data}"})
        result.output.match(data).should_not be nil

        expect(subject.close).to be true
      end

      it "should allow us to change the expected exit code" do
        subject.config do |config|
          config.ui = @ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
          config.proxy_user = ENV["USER"]
          config.proxy_host_name = "127.0.0.1"
        end
        data = 32
        result = subject.exec(%Q{/bin/bash -c 'exit #{data}'}, :exit_code => data)

        expect(subject.close).to be true
      end

      it "should allow us to execute a bootstrap script" do
        subject.config do |config|
          config.ui = @ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
        end
        data = "Hello World @ #{Time.now.utc}"

        result = subject.bootstrap(<<-EOBOOTSTRAP)
echo "#{data}" >&1
EOBOOTSTRAP

        expect(result.output).to match(/#{data}/)

        expect(subject.close).to be true
      end

      it "should allow us to write a file" do
        subject.config do |config|
          config.ui = @ui

          config.user = ENV["USER"]
          config.host_name = "127.0.0.1"
        end
        data = "Hello World @ #{Time.now.utc}"
        test_filename = File.join("", "tmp", "test_file.txt")

        subject.file(:target => test_filename) do |f|
          f.write(data)
        end

        result = subject.exec(%Q{cat #{test_filename}})

        expect(result.output).to match(/#{data}/)

        expect(subject.close).to be true
      end

      describe "stdout" do

        it "should capture STDOUT (with PTY) and send it to the STDOUT pipe" do
          subject.config do |config|
            config.ui = @ui

            config.user = ENV["USER"]
            config.host_name = "127.0.0.1"
            config.proxy_user = ENV["USER"]
            config.proxy_host_name = "127.0.0.1"
          end
          data = "Hello World @ #{Time.now.utc}"

          subject.exec(%Q{echo "#{data}" >&1})

          @ui.stdout.rewind
          expect(@ui.stdout.read).to match(/#{data}/)

          @ui.stderr.rewind
          expect(@ui.stderr.read).to be_empty

          @ui.stdin.rewind
          expect(@ui.stdin.read).to be_empty

          expect(subject.close).to be true
        end

        it "should capture STDOUT (without PTY) and send it to the STDOUT pipe" do
          subject.config do |config|
            config.ui = @ui

            config.user = ENV["USER"]
            config.host_name = "127.0.0.1"
            config.proxy_user = ENV["USER"]
            config.proxy_host_name = "127.0.0.1"

            config.request_pty = false
          end
          data = "Hello World @ #{Time.now.utc}"

          subject.exec(%Q{echo "#{data}" >&1})

          @ui.stdout.rewind
          expect(@ui.stdout.read).to match(/#{data}/)

          @ui.stderr.rewind
          expect(@ui.stderr.read).to be_empty

          @ui.stdin.rewind
          expect(@ui.stdin.read).to be_empty

          expect(subject.close).to be true
        end

      end

      describe "stderr" do

        it "should capture STDERR (with PTY) and send it to the STDOUT pipe" do
          subject.config do |config|
            config.ui = @ui

            config.user = ENV["USER"]
            config.host_name = "127.0.0.1"
            config.proxy_user = ENV["USER"]
            config.proxy_host_name = "127.0.0.1"
          end
          data = "Hello World @ #{Time.now.utc}"

          subject.exec(%Q{echo "#{data}" >&2})

          @ui.stdout.rewind
          expect(@ui.stdout.read).to match(/#{data}/)

          @ui.stderr.rewind
          expect(@ui.stderr.read).to be_empty

          @ui.stdin.rewind
          expect(@ui.stdin.read).to be_empty

          expect(subject.close).to be true
        end

        it "should capture STDERR (without PTY) and send it to the STDERR pipe" do
          subject.config do |config|
            config.ui = @ui

            config.user = ENV["USER"]
            config.host_name = "127.0.0.1"
            config.proxy_user = ENV["USER"]
            config.proxy_host_name = "127.0.0.1"

            config.request_pty = false
          end
          data = "Hello World @ #{Time.now.utc}"

          subject.exec(%Q{echo "#{data}" >&2})

          @ui.stdout.rewind
          expect(@ui.stdout.read).to be_empty

          @ui.stderr.rewind
          expect(@ui.stderr.read).to match(/#{data}/)

          @ui.stdin.rewind
          expect(@ui.stdin.read).to be_empty

          expect(subject.close).to be true
        end

      end

    end

    describe "upload" do

      [true, false].each do |use_scp|
        it "should be able to upload a file to 127.0.0.1 as the current user #{use_scp ? 'scp' : 'sftp'} (your key must be in ssh-agent)" do
          subject.config do |config|
            config.ui = @ui

            config.user = ENV["USER"]
            config.host_name = "127.0.0.1"
            config.proxy_user = ENV["USER"]
            config.proxy_host_name = "127.0.0.1"
          end

          data = "Hello World @ #{Time.now.utc}"

          remote_temp = Tempfile.new('remote')
          remote_file = File.join(ZTK::Locator.root, "tmp", File.basename(remote_temp.path.dup))
          remote_temp.close
          File.exists?(remote_file) && File.delete(remote_file)

          local_temp = Tempfile.new('local')
          local_file = File.join(ZTK::Locator.root, "tmp", File.basename(local_temp.path.dup))
          local_temp.close
          if RUBY_VERSION < "1.9.3"
            File.open(local_file, 'w') do |file|
              file.puts(data)
            end
          else
            IO.write(local_file, data)
          end

          File.exists?(remote_file).should == false
          subject.upload(local_file, remote_file, :use_scp => use_scp)
          File.exists?(remote_file).should == true

          File.exists?(remote_file) && File.delete(remote_file)
          File.exists?(local_file) && File.delete(local_file)

          expect(subject.close).to be true
        end
      end

    end

    describe "download" do

      [true, false].each do |use_scp|
        it "should be able to download a file from 127.0.0.1 as the current user using #{use_scp ? 'scp' : 'sftp'} (your key must be in ssh-agent)" do
          subject.config do |config|
            config.ui = @ui

            config.user = ENV["USER"]
            config.host_name = "127.0.0.1"
            config.proxy_user = ENV["USER"]
            config.proxy_host_name = "127.0.0.1"
          end

          data = "Hello World @ #{Time.now.utc}"

          local_temp = Tempfile.new('local')
          local_file = File.join(ZTK::Locator.root, "tmp", File.basename(local_temp.path.dup))
          local_temp.close
          File.exists?(local_file) && File.delete(local_file)

          remote_temp = Tempfile.new('remote')
          remote_file = File.join(ZTK::Locator.root, "tmp", File.basename(remote_temp.path.dup))
          remote_temp.close
          if RUBY_VERSION < "1.9.3"
            File.open(remote_file, 'w') do |file|
              file.puts(data)
            end
          else
            IO.write(remote_file, data)
          end

          File.exists?(local_file).should == false
          subject.download(remote_file, local_file, :use_scp => use_scp)
          File.exists?(local_file).should == true

          File.exists?(local_file) && File.delete(local_file)
          File.exists?(remote_file) && File.delete(remote_file)

          expect(subject.close).to be true
        end
      end

    end

  end

end
