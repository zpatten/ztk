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
      if has_many_references.key?(key)
        has_many_references[key]
      else
        has_many_references[key] ||= []
        # 1. Find items that "belong to" us
        # 2. Lookup those items on the destination object
        #
        # dataset = key.to_s.classify.constantize.all
        # look up data and set references
      end
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
        has_many_relations[key] = {:key => key}.merge(options)

        define_method(key) do |*args|
          if args.count == 0
            get_has_many_reference(key)
          else
            send("#{key}=", *args)
          end
        end

        define_method("#{key}=") do |value|
          dataset = get_has_many_reference(key)
          dataset.clear
          dataset.concat(value)
        end

        define_method(singularize(key)) do |&block|
          puts get_has_many_reference(key).inspect
          data = constantize(classify(key.to_s)).new(&block)
          get_has_many_reference(key) << data
          data
        end
      end
    end

  end
end
