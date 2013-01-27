module ZTK::DSL
  module Core
    autoload :Attributes, "ztk/dsl/core/attributes"
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

      def camelize(str)
        string = str.to_s
        parts = string.split("_")
        string = parts.collect{ |part| part.capitalize }.join
        string
      end

      def classify(str)
        string = str.to_s
        camelize(singularize(string))
      end

      # Ruby 1.9 introduces an inherit argument for Module#const_get and
      # #const_defined? and changes their default behavior.
      if Module.method(:const_get).arity == 1
        # Tries to find a constant with the name specified in the argument string:
        #
        #   "Module".constantize     # => Module
        #   "Test::Unit".constantize # => Test::Unit
        #
        # The name is assumed to be the one of a top-level constant, no matter whether
        # it starts with "::" or not. No lexical context is taken into account:
        #
        #   C = 'outside'
        #   module M
        #     C = 'inside'
        #     C               # => 'inside'
        #     "C".constantize # => 'outside', same as ::C
        #   end
        #
        # NameError is raised when the name is not in CamelCase or the constant is
        # unknown.
        def constantize(camel_cased_word)
          names = camel_cased_word.split('::')
          names.shift if names.empty? || names.first.empty?

          constant = Object
          names.each do |name|
            constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
          end
          constant
        end
      else
        def constantize(camel_cased_word) #:nodoc:
          names = camel_cased_word.split('::')
          names.shift if names.empty? || names.first.empty?

          constant = Object
          names.each do |name|
            constant = constant.const_defined?(name, false) ? constant.const_get(name) : constant.const_missing(name)
          end
          constant
        end
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
          code = %Q{
            unless defined?(@@#{arg})
              @@#{arg} = nil
            end

            def #{arg}
              @@#{arg}
            end
          }
          instance_eval(code, __FILE__, __LINE__)
        end
      end

      def cattr_writer(*args)
        args.flatten.each do |arg|
          next if arg.is_a?(Hash)
          code = %Q{
            unless defined?(@@#{arg})
              @@#{arg} = nil
            end

            def #{arg}=(value)
              @@#{arg} = value
            end
          }
          instance_eval(code, __FILE__, __LINE__)
        end
      end
    end

  end
end
