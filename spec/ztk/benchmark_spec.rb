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

describe ZTK::Benchmark do

  before(:each) do
    @ui = ZTK::UI.new(
      :stdout => StringIO.new,
      :stderr => StringIO.new,
      :stdin => StringIO.new
    )
  end

  subject { ZTK::Benchmark }

  describe "class" do

    it "should be ZTK::Benchmark" do
      subject.should be ZTK::Benchmark
    end

  end

  describe "behaviour" do

    it "should throw an exception if executed without a block" do
      lambda {
        ZTK::Benchmark.bench
      }.should raise_error ZTK::BenchmarkError, "You must supply a block!"
    end

    it "should return the benchmark of the given block" do
      mark = ZTK::Benchmark.bench do
        sleep(0.1)
      end
      mark.should be_an_instance_of Float
    end

    it "should not throw an exception if executed with a message but without a mark" do
      expect {
        ZTK::Benchmark.bench(:ui => @ui, :message => "Hello World") do
        end
      }.not_to raise_error
    end

    it "should not throw an exception if executed without a message but with a mark" do
      expect {
        ZTK::Benchmark.bench(:ui => @ui, :mark => "%0.4f") do
        end
      }.not_to raise_error
    end

    it "should not write to STDOUT if not given a message or mark" do
      ZTK::Benchmark.bench(:ui => @ui, :use_spinner => false) do
        sleep(0.1)
      end
      @ui.stdout.size.should == 0
    end

    it "should write to STDOUT if given a message and mark" do
      ZTK::Benchmark.bench(:ui => @ui, :message => "Hello World", :mark => "%0.4f") do
        sleep(0.1)
      end
      @ui.stdout.size.should > 0
    end

  end

end
