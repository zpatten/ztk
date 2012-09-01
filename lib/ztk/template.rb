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

require "erubis"

################################################################################

module ZTK

################################################################################

  class TemplateError < Error; end

################################################################################

  class Template

################################################################################

    class << self

################################################################################

      def render(template, context=nil)
        render_template(load_template(template), context)
      end

################################################################################
    private
################################################################################

      def load_template(template)
        IO.read(template).chomp
      end

################################################################################

      def render_template(template, context)
        Erubis::Eruby.new(template).evaluate(:config => context)
      end

################################################################################

    end

################################################################################

  end

################################################################################

end

################################################################################
