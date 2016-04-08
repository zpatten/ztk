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

describe ZTK::Profiler do

  let(:ui) { ZTK::UI.new(:stdout => StringIO.new, :stderr => StringIO.new, :stdin => StringIO.new) }

  subject { ZTK::Profiler }

  describe "class" do

    it "should be ZTK::Profiler" do
      expect(subject).to be ZTK::Profiler
    end

  end

  before(:each) { subject.reset }

  describe "methods" do

    describe "#reset" do

      it "should reset the timings" do
        subject.start
        sleep(0.5)
        expect(subject.total_time).to be > 0.0
        total_time = subject.total_time

        subject.start
        expect(subject.total_time).to be > 0.0
        expect(subject.total_time).to be < total_time
      end

    end

    describe "#start" do

      it "should start the profiler" do
        subject.start
        expect(subject.total_time).to be > 0.0
      end

    end

    describe "#total_time" do

      it "should report the total time of the profiling" do
        subject.start
        expect(subject.total_time).to be > 0.0
      end

      it "should raise an exception if the profiler is not started first" do
        expect{subject.total_time}.to raise_error ZTK::ProfilerError
      end

    end

    describe "#report" do

      it "should return a report of the profile timings" do
        subject.start
        subject.operation_a do
          sleep(0.1)
        end

        report = subject.report(:ui => ui)

        expect(report).to be_kind_of Array

        expect(report.first).to be_kind_of Hash
        expect(report.first.keys.first).to be == :operation_a
        expect(report.first.values.first).to be_kind_of Float

        expect(report.last).to be_kind_of Hash
      end
    end

  end

end
