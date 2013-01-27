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

      def singularize(string)
        if string =~ /s$/
          string = string[0..-2]
        end
        string
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
