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

  let(:ui) { ZTK::UI.new(:stdout => StringIO.new, :stderr => StringIO.new, :stdin => StringIO.new) }

  subject { ZTK::SSH.new }

  describe "class" do

    it "should be an instance of ZTK::SSH" do
      expect(subject).to be_an_instance_of ZTK::SSH
    end

  end

  [ :direct, :proxy ].each do |connection_type|

    before(:each) do
      subject.config do |config|
        config.ui = ui
        config.user = ENV["USER"]
        config.host_name = "127.0.0.1"

        if connection_type == :proxy
          config.proxy_user = ENV["USER"]
          config.proxy_host_name = "127.0.0.1"
        end
      end
    end

    describe "#console (#{connection_type})" do

      it "should execute a console" do
        expect(Kernel).to receive(:exec)

        subject.console
      end

    end

    describe "#execute (#{connection_type})" do

      it "should be able to connect to 127.0.0.1 as the current user and execute a command (your key must be in ssh-agent)" do
        data = %x(hostname).chomp

        status = subject.exec("hostname")
        expect(status.exit_code).to equal 0

        ui.stdout.rewind
        expect(ui.stdout.read.chomp).to match data

        expect(subject.close).to be true
      end

      it "should timeout after the period specified" do
        subject.config.timeout = WAIT_SMALL

        expect { subject.exec("sleep 10") }.to raise_error ZTK::SSHError

        expect(subject.close).to be true
      end

      it "should throw an exception if the exit status is not as expected" do
        expect { subject.exec("exit 42") }.to raise_error ZTK::SSHError

        expect(subject.close).to be true
      end

      it "should return a instance of an OpenStruct object" do
        result = subject.exec(%{echo "Hello World"})
        expect(result).to be_an_instance_of OpenStruct

        expect(subject.close).to be true
      end

      it "should return the exit code" do
        data = 64

        result = subject.exec(%{exit #{data}}, :exit_code => data)
        expect(result.exit_code).to equal data

        expect(subject.close).to be true
      end

      it "should return the output" do
        data = "Hello World @ #{Time.now.utc}"

        result = subject.exec(%Q{echo "#{data}"})
        expect(result.output).to match data

        expect(subject.close).to be true
      end

      it "should allow us to change the expected exit code" do
        data = 32

        result = subject.exec(%{exit #{data}}, :exit_code => data)
        expect(result.exit_code).to equal data

        expect(subject.close).to be true
      end

      it "should allow us to execute a bootstrap script" do
        data = "Hello World @ #{Time.now.utc}"

        result = subject.bootstrap(<<-EOBOOTSTRAP)
echo "#{data}" >&1
EOBOOTSTRAP
        expect(result.output.chomp).to match data

        expect(subject.close).to be true
      end

      it "should allow us to write a file" do
        data = "Hello World @ #{Time.now.utc}"
        test_filename = File.join("", "tmp", "test_file.txt")

        subject.file(:target => test_filename) do |f|
          f.write(data)
        end

        result = subject.exec(%{cat #{test_filename}})
        expect(result.output.chomp).to match data

        expect(subject.close).to be true
      end

    end #execute

    describe "#ui (#{connection_type})" do

      describe "#stdout (#{connection_type})" do

        [true, false].each do |request_pty|

          it "should capture STDOUT #{request_pty ? "with" : "without"} PTY and send it to the STDOUT pipe" do
            subject.config.request_pty = request_pty
            data = "Hello World @ #{Time.now.utc}"

            subject.exec(%{echo "#{data}" >&1})

            ui.stdout.rewind
            expect(ui.stdout.read).to match data

            ui.stderr.rewind
            expect(ui.stderr.read).to be_empty

            ui.stdin.rewind
            expect(ui.stdin.read).to be_empty

            expect(subject.close).to be true
          end

        end

      end #stdout

      describe "#stderr (#{connection_type})" do

        [true, false].each do |request_pty|

          it "should capture STDERR #{request_pty ? "with" : "without"} PTY and send it to the #{request_pty ? "STDOUT" : "STDERR"} pipe" do
            subject.config.request_pty = request_pty
            data = "Hello World @ #{Time.now.utc}"

            subject.exec(%{echo "#{data}" >&2})

            ui.stdout.rewind
            expect(ui.stdout.read).to (request_pty ? match(data) : be_empty)

            ui.stderr.rewind
            expect(ui.stderr.read).to (request_pty ? be_empty : match(data))

            ui.stdin.rewind
            expect(ui.stdin.read).to be_empty

            expect(subject.close).to be true
          end

        end

      end #stderr

    end #ui

    describe "#upload (#{connection_type})" do

      [true, false].each do |use_scp|
        it "should be able to upload a file to 127.0.0.1 as the current user using #{use_scp ? 'scp' : 'sftp'} (your key must be in ssh-agent)" do
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

          expect(File.exists?(remote_file)).to be false
          subject.upload(local_file, remote_file, :use_scp => use_scp)
          expect(File.exists?(remote_file)).to be true

          File.exists?(remote_file) && File.delete(remote_file)
          File.exists?(local_file) && File.delete(local_file)

          expect(subject.close).to be true
        end
      end

    end #upload

    describe "#download (#{connection_type})" do

      [true, false].each do |use_scp|
        it "should be able to download a file from 127.0.0.1 as the current user using #{use_scp ? 'scp' : 'sftp'} (your key must be in ssh-agent)" do
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

          expect(File.exists?(local_file)).to be false
          subject.download(remote_file, local_file, :use_scp => use_scp)
          expect(File.exists?(local_file)).to be true

          File.exists?(local_file) && File.delete(local_file)
          File.exists?(remote_file) && File.delete(remote_file)

          expect(subject.close).to be true
        end
      end

    end #download

  end

end
