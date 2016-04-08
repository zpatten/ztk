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

describe ZTK::Config do

  subject do
    class C
      extend(ZTK::Config)
    end
  end

  describe "class" do

    it "should be a kind of ZTK::Config" do
      expect(subject).to be_a_kind_of ZTK::Config
    end

    describe "default config" do

      it "should have an OpenStruct object for holding the configuration" do
        expect(subject.configuration).to be_an_instance_of OpenStruct
        expect(subject.keys.length).to be == 0
      end

    end

  end

  describe "behaviour" do

    it "should allow setting of arbratary configuration keys" do
      subject.thing = "something"

      expect(subject.thing).to be == "something"
      expect(subject[:thing]).to be == "something"
    end

    it "should allow hash bracket style access to configuration keys" do
      subject[:thing] = "nothing"

      expect(subject[:thing]).to be == "nothing"
    end

    it "should allow loading of configurations from disk" do
      config_file = File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "test-config.rb"))
      subject.from_file(config_file)

      expect(subject.message).to be == "Hello World"
      expect(subject.thing).to be == 2
    end

  end

end
