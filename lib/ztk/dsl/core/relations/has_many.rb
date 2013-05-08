module ZTK::DSL::Core::Relations

  # @author Zachary Patten <zachary AT jovelabs DOT com>
  # @api private
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
      end
    end

    def set_has_many_reference(key, value)
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

    # @author Zachary Patten <zachary AT jovelabs DOT com>
    module ClassMethods

      def has_many(key, options={})
        has_many_relations[key] = {
          :class_name => key.to_s.classify,
          :key => key
        }.merge(options)

################################################################################

        # Ruby-1.8.7 Logic:
        ####################
        module_eval <<-CODE, __FILE__, __LINE__ + 1
          def #{key}(*args)
            if args.count == 0
              get_has_many_reference(#{key.inspect})
            else
              send("#{key}=", *args)
            end
          end
        CODE

        # > Ruby-1.8.7 Logic:
        ######################
        # define_method(key) do |*args|
        #   if args.count == 0
        #     get_has_many_reference(key)
        #   else
        #     send("#{key}=", *args)
        #   end
        # end

################################################################################

        # Ruby-1.8.7 Logic:
        ####################
        module_eval <<-CODE, __FILE__, __LINE__ + 1
          def #{key}=(value)
            set_has_many_reference(#{key.inspect}, value)
          end
        CODE

        # > Ruby-1.8.7 Logic:
        ######################
        # define_method("#{key}=") do |value|
        #   set_has_many_reference(key, value)
        # end

################################################################################

        # Ruby-1.8.7 Logic:
        ####################
        module_eval <<-CODE, __FILE__, __LINE__ + 1
          def #{key.to_s.singularize}(id=nil, &block)
            options = self.class.has_many_relations[#{key.inspect}]
            data = options[:class_name].constantize.new(id, &block)
            get_has_many_reference(#{key.inspect}) << data

            klass = self.class.to_s.demodulize.singularize.downcase + '='

            data.send(klass, self)
            data
          end
        CODE

        # > Ruby-1.8.7 Logic:
        ######################
        # define_method(key.to_s.singularize) do |id=nil, &block|
        #   options = self.class.has_many_relations[key]
        #   data = options[:class_name].constantize.new(id, &block)
        #   get_has_many_reference(key) << data

        #   klass = self.class.to_s.demodulize.singularize.downcase

        #   data.send("#{klass}=", self)
        #   data
        # end
      end

    end

  end
end
