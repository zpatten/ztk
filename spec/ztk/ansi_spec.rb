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

describe "ZTK::ANSI Module" do

  subject { ZTK::ANSI }

  describe "module" do

    it "should be ZTK::ANSI" do
      expect(subject).to be ZTK::ANSI
    end

  end

end

describe "ZTK::ANSI Monkey-Patch String Class" do

  subject do
    class String
      include ZTK::ANSI
    end
  end

  describe "class" do

    it "should include ZTK::ANSI" do
      expect(subject.include?(ZTK::ANSI)).to be true
    end

  end

  describe "methods" do

    ZTK::ANSI::ANSI_COLORS.each do |color, code|

      it "should color the string #{color}" do
        expect(subject.new("#{color}").send(color)).to match(/#{color}/)
        expect(subject.new("#{color}").send(color)).to match(/#{code}/)
      end

      it "should remove #{color} color from the string" do
        expect(subject.new("#{color}").send(color).uncolor).to match(/#{color}/)
        expect(subject.new("#{color}").send(color).uncolor).not_to match(/#{code}/)
      end


      it "should reset the screen and color the string #{color}" do
        expect(subject.new("#{color}").send(color).reset).to match(/#{color}/)
        expect(subject.new("#{color}").send(color).reset).to match(/#{code}/)
        expect(subject.new("#{color}").send(color).reset).to start_with("\e[2J")
      end

    end

    x, y = Random.rand(25), Random.rand(25)
    it "should move the cursor to #{x},#{y}" do
      expect(subject.new.goto(x,y)).to start_with("\e[#{x};#{y}H")
    end

  end

end
