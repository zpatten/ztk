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
require 'pty'

module ZTK

  # ZTK::PTY Error Class
  # @author Zachary Patten <zachary AT jovelabs DOT net>
  class PTYError < Error; end

  # Ruby PTY Class Wrapper
  # @author Zachary Patten <zachary AT jovelabs DOT net>
  class PTY

    class << self

      # Wraps the Ruby PTY class, providing better functionality.
      #
      # @param [Array] args An argument splat to be passed to PTY::spawn
      #
      # @return [Object] Returns the $? object.
      def spawn(*args, &block)

        if block_given?
          ::PTY.spawn(*args) do |reader, writer, pid|
            begin
              yield(reader, writer, pid)
            rescue Errno::EIO
            ensure
              ::Process.wait(pid)
            end
          end
        else
          reader, writer, pid = ::PTY.spawn(*args)
        end

        [reader, writer, pid]
      end

    end

  end

end
