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

module ZTK::DSL::Core::Relations
  module HasMany

    def self.included(base)
      base.class_eval do
        base.add_relation(:has_many)
        base.send(:extend, ZTK::DSL::Core::Relations::HasMany::ClassMethods)
      end
    end

    def has_many_references
      @has_many_references ||= {}
    end

    def get_has_many_reference(key)
      logger.debug { "key(#{key})" }

      if has_many_references.key?(key)
        logger.debug { "found key -> (#{key})" }

        has_many_references[key]
      else
        logger.debug { "looking up key -> (#{key})" }

        has_many_references[key] ||= []
      end
    end

    def set_has_many_reference(key, value)
      logger.debug { "key(#{key}), value(#{value})" }

      dataset = get_has_many_reference(key)
      dataset.clear
      dataset.concat(value)
    end

    def save_has_many_references
      has_many_references.each do |key, dataset|
        dataset.each do |data|
          # do something to store the data somewhere
        end
      end
    end

    module ClassMethods

      def has_many(key, options={})
        has_many_relations[key] = {
          :class_name => key.to_s.classify,
          :key => key
        }.merge(options)
        logger.debug { "key(#{key.inspect}), options(#{has_many_relations[key].inspect})" }

        define_method(key) do |*args|
          logger.debug { "#{key} *args(#{args.inspect})" }

          if args.count == 0
            get_has_many_reference(key)
          else
            send("#{key}=", *args)
          end
        end

        define_method("#{key}=") do |value|
          logger.debug { "#{key}= value(#{value.inspect})" }

          set_has_many_reference(key, value)
        end

        define_method(key.to_s.singularize) do |&block|
          options = self.class.has_many_relations[key]
          logger.debug { "#{key.to_s.singularize} block(#{block.inspect}), options(#{options.inspect})" }
          data = options[:class_name].constantize.new(&block)
          get_has_many_reference(key) << data
          klass = self.class.to_s.demodulize.singularize.downcase
          logger.debug { "send(#{klass})" }
          data.send("#{klass}=", self)
          data
        end
      end

    end

  end
end
