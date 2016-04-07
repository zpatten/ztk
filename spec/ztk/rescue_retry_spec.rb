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

describe ZTK::RescueRetry do

  subject { ZTK::RescueRetry }

  describe "class" do

    it "should be ZTK::RescueRetry" do
      expect(subject).to be ZTK::RescueRetry
    end

  end

  describe "behaviour" do

    it "should throw an exception if executed without a block" do
      expect do
        ZTK::RescueRetry.try(:tries => 5)
      end.to raise_error ZTK::RescueRetryError
    end

    it "should retry on all exceptions by default if one is not supplied" do
      $counter = 0
      expect do
        ZTK::RescueRetry.try(:tries => 3) do
          $counter += 1
          raise "TestException"
        end
      end.to raise_error "TestException"
      expect($counter).to be == 3
    end

    it "should retry on supplied exception" do
      $counter = 0
      expect do
        ZTK::RescueRetry.try(:tries => 3, :on => EOFError) do
          $counter += 1
          raise EOFError
        end
      end.to raise_error EOFError
      expect($counter).to be == 3
    end

    it "should not retry on exception if it does not match the supplied exception" do
      $counter = 0
      expect do
        ZTK::RescueRetry.try(:tries => 3, :on => EOFError) do
          $counter += 1
          raise "TestException"
        end
      end.to raise_error "TestException"
      expect($counter).to be == 1
    end

    it "should call our lambda when it catches an exception and retries" do
      $counter = 0
      on_retry_m = lambda { |exception|
        $counter += 1
      }
      expect do
        ZTK::RescueRetry.try(:tries => 3, :on => EOFError, :on_retry => on_retry_m) do
          raise EOFError
        end
      end.to raise_error EOFError
      expect($counter).to be == 2
    end

    it "should not retry exceptions that are ignored" do
      $counter = 0

      expect do
        ZTK::RescueRetry.try(:tries => 3, :raise => EOFError) do
          $counter += 1
          raise EOFError
        end
      end.to raise_error EOFError

      expect($counter).to be == 1
    end

  end

end
