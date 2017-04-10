################################################################################
#
#      Author: Zachary Patten <zpatten AT jovelabs DOT io>
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

describe ZTK::Parallel do

  subject { ZTK::Parallel.new }

  describe "class" do

    it "should be an instance of ZTK::Parallel" do
      expect(subject).to be_an_instance_of ZTK::Parallel
    end

  end

  describe "methods" do


    describe "#process" do

      it "should throw an exception if the process method is called without a block" do
        expect{ subject.process }.to raise_error ZTK::ParallelError
      end

      it "should spawn multiple processes to handle each iteration" do
        3.times do |x|
          subject.process do
            Process.pid
          end
        end

        subject.waitall

        subject.results.each{ |r| expect(r).to be_kind_of Integer }
        subject.results.each{ |r| expect(r).to be > 0 }
        expect(subject.results.uniq.count).to be == 3
        expect(subject.results.include?(Process.pid)).to be == false
      end

      it "should stop all execution when the ZTK::Parallel::Break exception is raised" do
        expect do

          3.times do |x|
            subject.process do
              raise ZTK::Parallel::Break
            end
          end

          subject.waitall

        end.to raise_error ZTK::Parallel::Break
      end

      it "should stop all execution when any exception is raised" do
        expect do
          3.times do |x|
            subject.process do
              raise "SomeException"
            end
          end

          subject.waitall
        end.to raise_error "SomeException"
      end

      it "should allow us to ignore exceptions" do
        subject = ZTK::Parallel.new(:raise_exceptions => false)

        expect do
          3.times do |x|
            subject.process do
              raise "SomeException"
            end
          end

          subject.waitall
        end.not_to raise_error "SomeException"
      end

      it "should not ignore ZTK::Parallel::Break exceptions" do
        subject = ZTK::Parallel.new(:raise_exceptions => false)

        expect do
          3.times do |x|
            subject.process do
              raise ZTK::Parallel::Break
            end
          end

          subject.waitall
        end.to raise_error ZTK::Parallel::Break
      end

      it "should raise ZTK::Parallel::Timeout if execution is longer than the limit set" do
        subject = ZTK::Parallel.new(:raise_exceptions => false, :child_timeout => 3)

        expect do
          subject.process do
            sleep 10
          end

          subject.waitall
        end.to raise_error ZTK::Parallel::Timeout
      end

    end

    describe "#wait" do

      it "should be able to incrementally wait the forks" do
        3.times do |x|
          subject.process do
            Process.pid
          end
        end

        while subject.count > 0 do
          subject.wait
        end

        subject.results.each{ |r| expect(r).to be_kind_of Integer }
        subject.results.each{ |r| expect(r).to be > 0 }
        expect(subject.results.uniq.count).to be == 3
        expect(subject.results.include?(Process.pid)).to be == false
      end

    end

    describe "#waitall" do

      it "should be able to wait for all forks to stop" do
        3.times do |x|
          subject.process do
            Process.pid
          end
        end

        subject.waitall
        expect(subject.count).to be == 0
      end

    end

    describe "#count" do

      it "should return the number of active forked processes" do
        3.times do |x|
          subject.process do
            Process.pid
          end
        end

        expected_count = ((3 > ZTK::Parallel::MAX_FORKS) ? ZTK::Parallel::MAX_FORKS : 3)

        expect(subject.count).to be == expected_count
        subject.waitall
      end

    end

  end

end
