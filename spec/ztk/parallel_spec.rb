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

describe ZTK::Parallel do

  before(:all) do
  end

  subject { ZTK::Parallel.new }

  it "should be of kind ZTK::Parallel class" do
    subject.should be_an_instance_of ZTK::Parallel
  end

  it "should spawn multiple processes to handle each iteration" do
    3.times do |x|
      subject.process do
        Process.pid
      end
    end
    subject.waitall
    puts subject.results.inspect
    subject.results.all?{ |r| r.should be_kind_of Integer }
    subject.results.all?{ |r| r.should > 0 }
    subject.results.count.should == 3
    subject.results.include?(Process.pid).should be false
  end

end
