################################################################################
#
#      Author: Zachary Patten <zachary AT jovelabs DOT net>
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
module ZTK
  class SSH

    module Bootstrap
      require 'tempfile'

      def bootstrap(content, use_sudo=true)
        tempfile = Tempfile.new("bootstrap")

        ::File.open(tempfile, 'w') do |file|
          file.puts(content)
          file.respond_to?(:flush) and file.flush
        end

        self.upload(tempfile.path, tempfile.path)

        command = Array.new
        command << %(sudo) if (use_sudo == true)
        command << %(/bin/bash)
        command << tempfile.path
        command = command.join(' ')

        self.exec(command, :silence => true)
      end

    end

  end
end
