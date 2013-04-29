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

  # ANSI Error Class
  # @author Zachary Patten <zachary@jovelabs.net>
  class ANSIError < Error; end

  # ANSI Mixin Module
  #
  # Include this module to enable easy ANSI coloring methods like:
  #
  #   "bold red".red.bold
  #
  # Or
  #
  #   "green".green
  #
  # Standard use is to mix this module into String.
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  module ANSI

    COLOR_MATRIX = {
      :black   => 30,
      :red     => 31,
      :green   => 32,
      :yellow  => 33,
      :blue    => 34,
      :magenta => 35,
      :cyan    => 36,
      :white   => 37
    }

    ATTRIBUTE_MATRIX = {
      :normal => 0,
      :bold   => 1
    }

    def self.build_ansi_methods(hash)
      hash.each do |key, value|
        define_method(key) do |string=nil, &block|
          result = Array.new
          result << %(\e[#{value}m)
          if block_given?
            result << yield
          elsif string.respond_to?(:to_str)
            result << string.to_str
          elsif respond_to?(:to_str)
            result << to_str
          else
            return result
          end
          result << %(\e[0m)

          result.join
        end
      end
    end

    build_ansi_methods(COLOR_MATRIX)
    build_ansi_methods(ATTRIBUTE_MATRIX)

    extend self

  end

end
