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
module ZTK

  # ZTK::Locator Error Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class LocatorError < Error; end

  # @author Zachary Patten <zachary@jovelabs.net>
  class Locator

    class << self

      # Locate a file or directory
      #
      # Attempts to locate the file or directory supplied, starting with
      # the current working directory and crawling it up looking for a match
      # at each step of the way.
      #
      # @param [String,Array<String>] args A string or array of strings to
      #   attempt to locate.
      #
      # @return [String] The expanded path to the located entry.
      def find(*args)
        pwd = Dir.pwd.split(File::SEPARATOR)

        (pwd.length - 1).downto(0) do |i|
          candidate = File.expand_path(File.join(pwd[0..i], args))
          return candidate if File.exists?(candidate)
        end

        raise LocatorError, "Could not locate '#{File.join(args)}'!"
      end

    end

  end

end
