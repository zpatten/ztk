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

describe ZTK::Spinner do

  subject { ZTK::Spinner }

  describe "class" do

    it "should be ZTK::Spinner" do
      expect(subject).to be ZTK::Spinner
    end

  end

  describe "behaviour" do

    it "should throw an exception if executed without a block" do
      expect do
        ZTK::Spinner.spin
      end.to raise_error ZTK::SpinnerError
    end

  end

end
