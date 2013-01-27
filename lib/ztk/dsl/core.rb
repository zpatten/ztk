module ZTK::DSL
  module Core
    autoload :Attributes, "ztk/dsl/core/attributes"
    autoload :Actions, "ztk/dsl/core/actions"
    autoload :IO, "ztk/dsl/core/io"
    autoload :Relations, "ztk/dsl/core/relations"

    def self.included(base)
      base.class_eval do
        base.send(:extend, ZTK::DSL::Core::ClassMethods)

        base.send(:extend, ZTK::DSL::Core::DualMethods)
        base.send(:include, ZTK::DSL::Core::DualMethods)
      end
    end

    module DualMethods

      def singularize(str)
        string = str.to_s
        if string =~ /s$/
          string = string[0..-2]
        end
        string
      end

      def camelize(underscored_word)
        string = underscored_word.to_s
        parts = string.split("_")
        string = parts.collect{ |part| part.capitalize }.join
        string
      end

      def classify(underscored_word)
        string = underscored_word.to_s
        camelize(singularize(string))
      end

      def constantize(camel_cased_word)
        names = camel_cased_word.to_s.split('::')
        (names.empty? || names.first.empty?) and names.shift

        constant = Object
        names.each do |name|
          if Module.method(:const_get).arity == 1
            constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
          else
            constant = constant.const_defined?(name, false) ? constant.const_get(name) : constant.const_missing(name)
          end
        end
        constant
      end

    end

    module ClassMethods

      def cattr_accessor(*args)
        cattr_reader(*args)
        cattr_writer(*args)
      end

      def cattr_reader(*args)
        args.flatten.each do |arg|
          next if arg.is_a?(Hash)
          instance_eval %Q{
            unless defined?(@@#{arg})
              @@#{arg} = nil
            end

            def #{arg}
              @@#{arg}
            end
          }
        end
      end

      def cattr_writer(*args)
        args.flatten.each do |arg|
          next if arg.is_a?(Hash)
          instance_eval %Q{
            unless defined?(@@#{arg})
              @@#{arg} = nil
            end

            def #{arg}=(value)
              @@#{arg} = value
            end
          }
        end
      end
    end

  end
end
