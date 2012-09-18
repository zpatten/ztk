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
  # Extend an existing class with this module to turn it into a singleton
  # configuration class.
  #
  # Given we have some code like:
  #
  #     class C
  #       extend(ZTK::Config)
  #     end
  #
  # We can then do things like:
  #
  #     C.thing = "something"
  #
  # or we can reference keys this way:
  #
  #     C[:thing] = "something"
  #
  # Accessing the value is just as simple:
  #
  #     puts C.thing
  #
  # We can also load configurations from disk.  Assuming we have a file (i.e. config.rb) like:
  #
  #     message  "Hello World"
  #     thing    (1+1)
  #
  # We can load it like so:
  #
  #     C.from_file("config.rb")
  #
  # Then we can reference the configuration defined in the file as easily as:
  #
  #     puts C.message
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

    # Loads a configuration from a file.
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

    # Get the value of a configuration key.
    #
    # @param [Symbol, String] key A symbol or string of the configuration
    #   key to return.
    #
    # @return The value currently assigned to the configuration key.
    def [](key)
      _get(key)
    end

    # Set the value of a configuration key.
    #
    # @param [Symbol, String] key A symbol or string of the configuration
    #   key to set.
    # @param value The value which you want to assign to the configuration
    #   key.
    #
    # @return The value assigned to the configuration key.
    def []=(key, value)
      _set(key, value)
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

    # Handles method calls for our configuration keys.
    def method_missing(method_symbol, *method_args)
      if method_args.length > 0
        _set(method_symbol, method_args.first)
      end

      _get(method_symbol)
    end


  private

    def _set(key, value)
      key = key.to_s
      (key =~ /=/) or key += '='

      self.configuration.send(key.to_sym, value)
    end

    def _get(key)
      key = key.to_s
      (key !~ /=/) or key = key[0..-2]

      self.configuration.send(key.to_sym)
    end

  end

end
