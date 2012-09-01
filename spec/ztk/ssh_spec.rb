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

describe ZTK::SSH do

  before(:all) do
  end

  subject { ZTK::SSH.new }

  it "should be of kind ZTK::SSH class" do
    subject.should be_an_instance_of ZTK::SSH
  end

  # this stuff doesn't work as is under travis-ci
  if !ENV['CI'] && !ENV['TRAVIS']

    it "should be able to connect to 127.0.0.1 as the current user" do
      subject.config do |config|
        config.ssh.user = ENV["USER"]
        config.ssh.host = "127.0.0.1"
      end
      hostname = %x( hostname -f ).chomp
      subject.exec("hostname -f").chomp.should == hostname
    end

  end

end
