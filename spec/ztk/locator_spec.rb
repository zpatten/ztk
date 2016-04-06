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

describe ZTK::Locator do

  subject { ZTK::Locator }

  describe "class" do

    it "should be ZTK::Locator" do
      expect(subject).to be ZTK::Locator
    end

    describe "methods" do

      describe "#find" do

        it "should find home" do
          expect(subject.find("home")).to be == "/home"
        end

        it "should not find funkytown_123_abc" do
          expect { subject.find("funkytown_123_abc") }.to raise_error ZTK::LocatorError
        end

      end

    end

  end

end
