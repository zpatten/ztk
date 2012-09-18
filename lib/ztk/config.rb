################################################################################
#
#      Author: Zachary Patten <zachary@jovelabs.net>
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

require 'ostruct'

module ZTK

  # ZTK::Config Error Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class ConfigError < Error; end

  # Configuration Module
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  module Config

    # Extend base class with this module.
    #
    # This will add the *configuration* attribute to the base class and create
    # a new *OpenStruct* object assigning it to the *configuration* attribute.
    def self.extended(base)
      class << base
        attr_accessor :configuration
      end

      base.configuration = OpenStruct.new
    end

    def from_file(filename)
      self.instance_eval(IO.read(filename), filename, 1)
    end

    # Yields the configuration OpenStruct object to a block.
    #
    # @yield [configuration] Pass the configuration OpenStruct object to the
    #   specified block.
    def config(&block)
      block and block.call(self.configuration)
    end

    # Get the value of a configuration option.
    #
    # @param [Symbol, String] option A symbol or string of the configuration
    #   option to return.
    #
    # @return The value currently assigned to the configuration option.
    def [](option)
      puts("[](#{option})")
      _get(option)
    end

    # Set the value of a configuration option.
    #
    # @param [Symbol, String] option A symbol or string of the configuration
    #   option to set.
    # @param value The value which you want to assign to the configuration
    #   option.
    #
    # @return The value assigned to the configuration option.
    def []=(option, value)
      puts("[]=(#{option}, #{value})")
      _set(option, value)
    end

    def method_missing(method_symbol, *method_args)
      puts("method_missing(#{method_symbol}, #{method_args})")
      if method_args.length > 0
        _set(method_symbol, method_args.first)
      end

      _get(method_symbol)
    end

    # @see Hash#keys
    def keys
      self.configuration.send(:table).keys
    end

    # @see Hash#has_key?
    def has_key?(key)
      self.configuration.send(:table).has_key?(key)
    end

    # @see Hash#merge
    def merge(hash)
      self.configuration.send(:table).merge(hash)
    end

    # @see Hash#merge!
    def merge!(hash)
      self.configuration.send(:table).merge!(hash)
    end


  private

    def _set(option, value)
      option = option.to_s
      (option =~ /=/) or option += '='

      puts("_set(#{option}, #{value})")
      self.configuration.send(option.to_sym, value)
    end

    def _get(option)
      option = option.to_s
      (option !~ /=/) or option = option[0..-2]

      puts("_get(#{option})")
      self.configuration.send(option.to_sym)
    end

  end

end
