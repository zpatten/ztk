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

describe ZTK::RescueRetry do

  subject { ZTK::RescueRetry }

  describe "class" do

    it "should be ZTK::RescueRetry" do
      subject.should be ZTK::RescueRetry
    end

  end

  describe "behaviour" do

    it "should throw an exception if executed without a block" do
      lambda {
        ZTK::RescueRetry.try(:tries => 5)
      }.should raise_error ZTK::RescueRetryError, "You must supply a block!"
    end

    it "should retry on all exceptions by default if one is not supplied" do
      $counter = 0
      lambda {
        ZTK::RescueRetry.try(:tries => 3) do
          $counter += 1
          raise "TestException"
        end
      }.should raise_error "TestException"
      $counter.should == 3
    end

    it "should retry on supplied exception" do
      $counter = 0
      lambda {
        ZTK::RescueRetry.try(:tries => 3, :on => EOFError) do
          $counter += 1
          raise EOFError
        end
      }.should raise_error EOFError
      $counter.should == 3
    end

    it "should not retry on exception if it does not match the supplied exception" do
      $counter = 0
      lambda {
        ZTK::RescueRetry.try(:tries => 3, :on => EOFError) do
          $counter += 1
          raise "TestException"
        end
      }.should raise_error "TestException"
      $counter.should == 1
    end

    it "should call our lambda when it catches an exception and retries" do
      $counter = 0
      on_retry_m = lambda { |exception|
        $counter +=1
      }
      lambda {
        ZTK::RescueRetry.try(:tries => 3, :on => EOFError, :on_retry => on_retry_m) do
          raise EOFError
        end
      }.should raise_error EOFError
      $counter.should == 2
    end

  end

end
