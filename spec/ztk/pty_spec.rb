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

describe ZTK::PTY do

  subject { ZTK::PTY }

  describe "class" do

    it "should be ZTK::PTY" do
      subject.should be ZTK::PTY
    end

  end

  describe "behaviour" do

    it "should spawn a command with a block" do
      lambda {
        subject.spawn("hostname") do |r, w, p|
        end
      }.should_not raise_error
    end

    it "should spawn a command without a block" do
      lambda {
        r, w, p = subject.spawn("hostname")
      }.should_not raise_error
    end

    describe "spawn" do

      it "should be able to spawn the command \"hostname\"" do
        data = %x(hostname).chomp
        output = nil

        subject.spawn("hostname") do |r, w, p|
          output = r.readpartial(READ_PARTIAL_CHUNK).chomp
        end

        output.should == data
      end

      it "should return the output of spawned commands" do
        data = "Hello World @ #{Time.now.utc}"
        output = nil

        subject.spawn(%(echo "#{data}")) do |r, w, p|
          output = r.readpartial(READ_PARTIAL_CHUNK).chomp
        end

        output.should == data
      end

      describe "stdout" do

        it "should capture stdout and send it to the reader" do
          data = "Hello World @ #{Time.now.utc}"
          output = nil

          subject.spawn(%(echo "#{data}" >&1)) do |r, w, p|
            output = r.readpartial(READ_PARTIAL_CHUNK).chomp
          end

          output.should == data
        end

      end

      describe "stderr" do

        it "should capture stderr and send it to the reader" do
          data = "Hello World @ #{Time.now.utc}"
          output = nil

          subject.spawn(%(echo "#{data}" >&2)) do |r, w, p|
            output = r.readpartial(READ_PARTIAL_CHUNK).chomp
          end

          output.should == data
        end

      end

    end

  end

end
