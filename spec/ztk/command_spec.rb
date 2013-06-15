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
require "os"

def shell(command)
  return OS.windows? && "cmd /c #{command}" || "/bin/bash -c '#{command}'"
end

describe ZTK::Command do

  before(:each) do
    @ui = ZTK::UI.new(
      :stdout => StringIO.new,
      :stderr => StringIO.new,
      :stdin => StringIO.new
    )
  end

  subject { ZTK::Command.new(:ui => @ui) }

  describe "class" do

    it "should be an instance of ZTK::Command" do
      subject.should be_an_instance_of ZTK::Command
    end

  end

  describe "behaviour" do

    describe "execute" do

      it "should be able to execute the command \"hostname\"" do
        subject.config do |config|
          config.ui = @ui
        end
        hostname = %x(hostname).chomp
        status = subject.exec("hostname")
        status.exit_code.should == 0
        @ui.stdout.rewind
        @ui.stdout.read.chomp.should == hostname
      end

      it "should timeout after the period specified" do
        subject.config do |config|
          config.ui = @ui
          config.timeout = WAIT_SMALL
        end
        hostname = %x(hostname).chomp
        lambda { subject.exec(shell("hostname; sleep 10")) }.should raise_error ZTK::CommandError
      end

      it "should throw an exception if the exit status is not as expected" do
        subject.config do |config|
          config.ui = @ui
        end
        lambda { subject.exec(shell("exit 64")) }.should raise_error ZTK::CommandError
      end

      it "should return a instance of an OpenStruct object" do
        subject.config do |config|
          config.ui = @ui
        end
        result = subject.exec(shell("echo 'Hello World'"))
        result.should be_an_instance_of OpenStruct
      end

      it "should return the exit code" do
        subject.config do |config|
          config.ui = @ui
        end
        data = 64

        result = subject.exec(shell("exit #{data}"), :exit_code => data)
        result.exit_code.should == data
      end

      it "should return the output" do
        subject.config do |config|
          config.ui = @ui
        end
        data = "Hello World @ #{Time.now.utc}"

        result = subject.exec(shell("echo #{data}"))
        result.output.match(data).should_not be nil
      end

      it "should allow us to change the expected exit code" do
        subject.config do |config|
          config.ui = @ui
        end
        data = 32
        result = subject.exec(shell("exit #{data}"), :exit_code => data)
      end

      describe "stdout" do

        it "should capture STDOUT and send it to the appropriate pipe" do
          subject.config do |config|
            config.ui = @ui
          end
          data = "Hello World @ #{Time.now.utc}"

          subject.exec("echo \"#{data}\" >&1")

          @ui.stdout.rewind
          @ui.stdout.read.match(data).should_not be nil

          @ui.stderr.rewind
          @ui.stderr.read.match(data).should be nil

          @ui.stdin.rewind
          @ui.stdin.read.match(data).should be nil
        end

      end

      describe "stderr" do

        it "should capture STDERR and send it to the appropriate pipe" do
          subject.config do |config|
            config.ui = @ui
          end
          data = "Hello World @ #{Time.now.utc}"

          subject.exec(%Q{echo "#{data}" >&2})

          @ui.stdout.rewind
          @ui.stdout.read.match(data).should be nil

          @ui.stderr.rewind
          @ui.stderr.read.match(data).should_not be nil

          @ui.stdin.rewind
          @ui.stdin.read.match(data).should be nil
        end
      end

    end

    describe "upload" do

      it "should raise a 'Not Supported' exception when attempting to upload" do
        lambda { subject.upload("abc", "123") }.should raise_error
      end

    end

    describe "download" do

      it "should raise a 'Not Supported' exception when attempting to download" do
        lambda { subject.download("abc", "123") }.should raise_error
      end

    end

  end

end
