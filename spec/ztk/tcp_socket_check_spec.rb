################################################################################
#
#      Author: Zachary Patten <zachary@jovelabs.com>
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

describe ZTK::TCPSocketCheck do

  subject { ZTK::TCPSocketCheck }

  describe "class" do

    it "should be ZTK::TCPSocketCheck" do
      subject.should be ZTK::TCPSocketCheck
    end

    describe "default config" do

      it "should throw an exception if the host is not specified" do
        lambda{ subject.new(:port => 22) }.should raise_error ZTK::TCPSocketCheckError, "You must supply a host!"
      end

      it "should throw an exception if the port is not specified" do
        lambda{ subject.new(:host => "127.0.0.1") }.should raise_error ZTK::TCPSocketCheckError, "You must supply a port!"
      end

    end

  end

  describe "behaviour" do

    it "should signal ready? is true on remote read test to github.com:22" do
      tcp_check = subject.new(:host => "github.com", :port => 22)
      tcp_check.ready?.should == true
    end

    it "should signal ready? is true on remote write test to www.google.com:80" do
      tcp_check = subject.new(:host => "www.google.com", :port => 80, :data => "GET")
      tcp_check.ready?.should == true
    end

  end

end
