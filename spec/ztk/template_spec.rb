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

describe ZTK::Template do

  subject { ZTK::Template }

  describe "class" do

    it "should be ZTK::Template" do
      expect(subject).to be ZTK::Template
    end

  end

  describe "methods" do

    describe "do_not_edit_notice" do

      it "should render the notice with no options" do
        result = subject.do_not_edit_notice
        expect(result).to be =~ /WARNING: AUTOMATICALLY GENERATED FILE; DO NOT EDIT!/
        expect(result).to be =~ /Generated @/
        expect(result).to be =~ /#/
      end

      it "should render the notice with our message inside" do
        message = "Hello World"
        result = subject.do_not_edit_notice(:message => message)
        expect(result).to be =~ /WARNING: AUTOMATICALLY GENERATED FILE; DO NOT EDIT!/
        expect(result).to be =~ /Generated @/
        expect(result).to be =~ /#/
        expect(result).to be =~ /#{message}/
      end

      it "should allow us to change the comment character" do
        message = "Hello World"
        char = "ZZ"
        result = subject.do_not_edit_notice(:message => message, :char => char)
        expect(result).to be =~ /WARNING: AUTOMATICALLY GENERATED FILE; DO NOT EDIT!/
        expect(result).to be =~ /Generated @/
        expect(result).to be =~ /#{message}/
        expect(result).to be =~ /#{char}/
      end

    end

    describe "render" do

      it "should render the template with the supplied context" do
        template_file = File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "test-template.txt.erb"))
        context = { :test_variable => "Hello World" }
        output = subject.render(template_file, context)

        expect(output).to be == "Hello World"
      end

    end

  end

end
