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

describe ZTK::Command do

  let(:ui) { ZTK::UI.new(:stdout => StringIO.new, :stderr => StringIO.new, :stdin => StringIO.new) }

  subject { ZTK::Command.new }

  describe "class" do

    it "should be an instance of ZTK::Command" do
      expect(subject).to be_an_instance_of ZTK::Command
    end

  end

  describe "behaviour" do

    describe "execute" do

      it "should be able to execute the command \"hostname\"" do
        subject.config.ui = ui

        hostname = %x(hostname).chomp
        status = subject.exec("hostname")
        expect(status.exit_code).to be == 0
        ui.stdout.rewind
        expect(ui.stdout.read.chomp).to match(hostname)
      end

      it "should timeout after the period specified" do
        subject.config do |config|
          config.ui = ui
          config.timeout = WAIT_SMALL
        end
        hostname = %x(hostname).chomp
        expect{ subject.exec("hostname ; sleep 10") }.to raise_error ZTK::CommandError
      end

      it "should throw an exception if the exit status is not as expected" do
        subject.config.ui = ui

        expect{ subject.exec("/bin/bash -c 'exit 64'") }.to raise_error ZTK::CommandError
      end

      it "should return a instance of an OpenStruct object" do
        subject.config.ui = ui

        result = subject.exec(%q{echo "Hello World"})
        expect(result).to be_an_instance_of OpenStruct
      end

      it "should return the exit code" do
        subject.config.ui = ui

        data = 64

        result = subject.exec(%{exit #{data}}, :exit_code => data)
        expect(result.exit_code).to be == data
      end

      it "should return the output" do
        subject.config.ui = ui

        data = "Hello World @ #{Time.now.utc}"

        result = subject.exec(%{echo "#{data}"})
        expect(result.output).to match(data)
      end

      it "should allow us to change the expected exit code" do
        subject.config.ui = ui

        data = 32
        result = subject.exec(%{exit #{data}}, :exit_code => data)
        expect(result.exit_code).to be == data
      end

      describe "stdout" do

        it "should capture STDOUT and send it to the appropriate pipe" do
          subject.config.ui = ui

          data = "Hello World @ #{Time.now.utc}"

          subject.exec(%{echo "#{data}" >&1})

          ui.stdout.rewind
          expect(ui.stdout.read).to match(data)

          ui.stderr.rewind
          expect(ui.stderr.read).to be_empty

          ui.stdin.rewind
          expect(ui.stdin.read).to be_empty
        end

      end

      describe "stderr" do

        it "should capture STDERR and send it to the appropriate pipe" do
          subject.config.ui = ui

          data = "Hello World @ #{Time.now.utc}"

          subject.exec(%{echo "#{data}" >&2})

          ui.stdout.rewind
          expect(ui.stdout.read).to be_empty

          ui.stderr.rewind
          expect(ui.stderr.read).to match(data)

          ui.stdin.rewind
          expect(ui.stdin.read).to be_empty
        end
      end

    end

    describe "upload" do

      it "should raise a 'Not Supported' exception when attempting to upload" do
        expect{ subject.upload("abc", "123") }.to raise_error ZTK::CommandError
      end

    end

    describe "download" do

      it "should raise a 'Not Supported' exception when attempting to download" do
        expect{ subject.download("abc", "123") }.to raise_error ZTK::CommandError
      end

    end

  end

end
