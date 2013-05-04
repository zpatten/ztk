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

module ZTK::DSL::Core::Relations

  # @author Zachary Patten <zachary AT jovelabs DOT net>
  # @api private
  module BelongsTo

    def self.included(base)
      base.class_eval do
        base.add_relation(:belongs_to)
        base.send(:extend, ZTK::DSL::Core::Relations::BelongsTo::ClassMethods)
      end
    end

    def belongs_to_references
      @belongs_to_references ||= {}
    end

    def get_belongs_to_reference(key)
      if belongs_to_references.key?(key)
        belongs_to_references[key]
      else
        key_id = send("#{key}_id")
        item = key.to_s.classify.constantize.find(key_id).first
        belongs_to_references[key] = item
      end
    end

    def set_belongs_to_reference(key, value)
      belongs_to_references[key] = value
      attributes.merge!("#{key}_id".to_sym => value.id)

      klass = self.class.to_s.demodulize.downcase.pluralize

      many = value.send(klass)
      many << self
      many.uniq!
    end

    def save_belongs_to_references
      belongs_to_references.each do |key, dataset|
        dataset.each do |data|
          # do something to store the data somewhere
        end
      end
    end

    # @author Zachary Patten <zachary AT jovelabs DOT net>
    module ClassMethods

      def belongs_to(key, options={})
        belongs_to_relations[key] = {
          :class_name => key.to_s.classify,
          :key => key
        }.merge(options)

        define_method(key) do |*args|
          if args.count == 0
            get_belongs_to_reference(key)
          else
            send("#{key}=", *args)
          end
        end

        define_method("#{key}=") do |value|
          set_belongs_to_reference(key, value)
        end

        define_method("#{key}_id") do |*args|
          if args.count == 0
            attributes["#{key}_id".to_sym]
          else
            send("#{key}_id=".to_sym, args.first)
          end

        end

        define_method("#{key}_id=") do |value|
          options = self.class.belongs_to_relations[key]
          if value != attributes["#{key}_id".to_sym]
            item = options[:class_name].constantize.find(value).first
            set_belongs_to_reference(key, item)
          else
            value
          end
        end

        # define_method(singularize(key)) do |value|
        #   set_belongs_to_reference(key, value)
        # end

        # define_method(singularize(key)) do |&block|
        #   puts get_belongs_to_reference(key).inspect
        #   data = constantize(classify(key.to_s)).new(&block)
        #   get_belongs_to_reference(key) << data
        #   data
        # end
      end

    end

  end
end
