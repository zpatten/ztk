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
require "erubis"

module ZTK

  # ZTK::Template Error Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class TemplateError < Error; end

  # Erubis Templating Class
  #
  # Given a template like this (i.e. "template.erb"):
  #
  #     This is a test template!
  #     <%= @variable %>
  #
  # We can do this:
  #
  #   ZTK::Template.render("template.erb", { :variable => "Hello World" })
  #
  # And get:
  #
  #     This is a test template!
  #     Hello World
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Template

    class << self

      # Renders a template to a string.
      #
      # @param [String] template The ERB template to process.
      # @param [Hash] context A hash containing key-pairs, for which the keys are turned into global variables with their respective values.
      #
      # @return [String] The evaulated template content.
      def render(template, context=nil)
        render_template(load_template(template), context)
      end


    private

      # Loads the template files contents.
      def load_template(template)
        IO.read(template).chomp
      end

      # Renders the template through Erubis.
      def render_template(template, context={})
        Erubis::Eruby.new(template).evaluate(context)
      end

    end

  end

end
