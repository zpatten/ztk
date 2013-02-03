################################################################################
#
#      Author: Zachary Patten <zachary@jovelabs.net>
#   Copyright: Copyright (c) Jove Labs
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
      subject.should be_an_instance_of ZTK::Parallel
    end

    describe "default config" do

      it "should use $stdout as the default" do
        subject.config.stdout.should be_a_kind_of $stdout.class
        subject.config.stdout.should == $stdout
      end

      it "should use $stderr as the default" do
        subject.config.stderr.should be_a_kind_of $stderr.class
        subject.config.stderr.should == $stderr
      end

      it "should use $stdin as the default" do
        subject.config.stdin.should be_a_kind_of $stdin.class
        subject.config.stdin.should == $stdin
      end

      it "should use $logger as the default" do
        subject.config.logger.should be_a_kind_of ZTK::Logger
        subject.config.logger.should == $logger
      end

    end

  end

  describe "behaviour" do

    it "should throw an exception if the process method is called without a block" do
      lambda{ subject.process }.should raise_error ZTK::ParallelError, "You must supply a block to the process method!"
    end

    it "should spawn multiple processes to handle each iteration" do
      3.times do |x|
        subject.process do
          Process.pid
        end
      end

      subject.waitall

      subject.results.all?{ |r| r.should be_kind_of Integer }
      subject.results.all?{ |r| r.should > 0 }
      subject.results.uniq.count.should == 3
      subject.results.include?(Process.pid).should be false
    end

    it "should be able to incrementally wait the forks" do
      3.times do |x|
        subject.process do
          Process.pid
        end
      end

      3.times do
        subject.wait
      end

      subject.results.all?{ |r| r.should be_kind_of Integer }
      subject.results.all?{ |r| r.should > 0 }
      subject.results.uniq.count.should == 3
      subject.results.include?(Process.pid).should be false
    end

  end

end
