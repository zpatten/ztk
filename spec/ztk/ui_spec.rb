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

describe ZTK::UI do

  subject { ZTK::UI.new }

  describe "class" do

    it "should be ZTK::UI" do
      expect(subject).to be_an_instance_of ZTK::UI
    end

  end

  describe "behaviour" do

    it "should return a class with accessors for stdout, stderr, stdin and a logger" do
      expect(subject.stdout).to be == $stdout
      expect(subject.stderr).to be == $stderr
      expect(subject.stdin).to be == $stdin
      expect(subject.logger).to be_an_instance_of ZTK::Logger
    end

    it "should allow us to set a custom STDOUT" do
      stdout = StringIO.new
      ui = ZTK::UI.new(:stdout => stdout)
      expect(ui.stdout).to be == stdout
    end

    it "should allow us to set a custom STDERR" do
      stderr = StringIO.new
      ui = ZTK::UI.new(:stderr => stderr)
      expect(ui.stderr).to be == stderr
    end

    it "should allow us to set a custom STDIN" do
      stdin = StringIO.new
      ui = ZTK::UI.new(:stdin => stdin)
      expect(ui.stdin).to be == stdin
    end

    it "should allow us to set a custom LOGGER" do
      logger = StringIO.new
      ui = ZTK::UI.new(:logger => logger)
      expect(ui.logger).to be == logger
    end

  end

end
