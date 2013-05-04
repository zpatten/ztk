################################################################################
#
#      Author: Zachary Patten <zachary AT jovelabs DOT net>
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

describe ZTK::Background do

  subject { ZTK::Background.new }

  describe "class" do

    it "should be an instance of ZTK::Background" do
      subject.should be_an_instance_of ZTK::Background
    end

  end

  describe "behaviour" do

    it "should throw an exception if the process method is called without a block" do
      lambda{ subject.process }.should raise_error ZTK::BackgroundError, "You must supply a block to the process method!"
    end

    describe "process" do

      it "should spawn a process to handle the task" do
        subject.process do
          Process.pid
        end

        subject.wait
        subject.result.should be_kind_of Integer
        subject.result.should > 0
        subject.result.should_not == Process.pid
      end

    end

    describe "alive?" do

      it "should respond true when the process is still running" do
        subject.process do
          sleep(WAIT_SMALL)
        end
        subject.alive?.should be true

        subject.wait
        subject.result.should be_kind_of Integer
        subject.result.should > 0
        subject.result.should == WAIT_SMALL
      end

      it "should respond false when the process is no longer running" do
        subject.process do
          Process.pid
        end
        subject.wait
        sleep(WAIT_SMALL)

        subject.alive?.should be false

        subject.result.should be_kind_of Integer
        subject.result.should > 0
        subject.result.should_not == Process.pid
      end

    end

    describe "dead?" do

      it "should respond false when the process is still running" do
        subject.process do
          sleep(WAIT_SMALL)
        end
        subject.dead?.should be false

        subject.wait
        subject.result.should be_kind_of Integer
        subject.result.should > 0
        subject.result.should == WAIT_SMALL
      end

      it "should respond true when the process is no longer running" do
        subject.process do
          Process.pid
        end
        subject.wait
        sleep(WAIT_SMALL)

        subject.dead?.should be true

        subject.result.should be_kind_of Integer
        subject.result.should > 0
        subject.result.should_not == Process.pid
      end

    end

    describe "result" do

      it "should marshal objects" do
        class BackgroundMarshalTest
          def hello_world
            "Hello World"
          end
        end

        subject.process do
          BackgroundMarshalTest.new
        end
        subject.wait

        subject.result.should be_kind_of BackgroundMarshalTest
        subject.result.hello_world.should == "Hello World"
      end

    end

  end

end
