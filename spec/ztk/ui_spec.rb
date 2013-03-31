################################################################################
#
#      Author: Zachary Patten <zachary@jovelabs.net>
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
      subject.should be_an_instance_of ZTK::UI
    end

  end

  describe "behaviour" do

    it "should return a class with accessors for stdout, stderr, stdin and a logger" do
      subject.stdout.should == $stdout
      subject.stderr.should == $stderr
      subject.stdin.should == $stdin
      subject.logger.should be_an_instance_of ZTK::Logger
    end

    it "should allow us to set a custom STDOUT" do
      stdout = StringIO.new
      ui = ZTK::UI.new(:stdout => stdout)
      ui.stdout.should == stdout
    end

    it "should allow us to set a custom STDERR" do
      stderr = StringIO.new
      ui = ZTK::UI.new(:stderr => stderr)
      ui.stderr.should == stderr
    end

    it "should allow us to set a custom STDIN" do
      stdin = StringIO.new
      ui = ZTK::UI.new(:stdin => stdin)
      ui.stdin.should == stdin
    end

    it "should allow us to set a custom LOGGER" do
      logger = StringIO.new
      ui = ZTK::UI.new(:logger => logger)
      ui.logger.should == logger
    end

  end

end
