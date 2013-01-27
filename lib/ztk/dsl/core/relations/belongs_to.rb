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
        constantize(classify(key.to_s))

        belongs_to_references[key] = nil
      end
    end

    def set_belongs_to_reference(key, value)
      belongs_to_references[key] = value
      attributes.merge!("#{key}_id" => value)
    end

    def save_belongs_to_references
      belongs_to_references.each do |key, dataset|
        dataset.each do |data|
          # do something to store the data somewhere
        end
      end
    end

    module ClassMethods

      def belongs_to(key, options={})
        has_many_relations[key] = {:key => key}.merge(options)

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
