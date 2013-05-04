require 'erubis'

module ZTK

  # ZTK::Template Error Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class TemplateError < Error; end

  # Erubis Templating Class
  #
  # Given a template like this (i.e. "template.erb"):
  #
  #     This is a test template!
  #     <%= @variable %>
  #
  # We can do this:
  #
  #   ZTK::Template.render("template.erb", { :variable => "Hello World" })
  #
  # And get:
  #
  #     This is a test template!
  #     Hello World
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Template

    class << self

      # Renders a template to a string.
      #
      # @param [String] template The ERB template to process.
      # @param [Hash] context A hash containing key-pairs, for which the keys are turned into global variables with their respective values.
      #
      # @return [String] The evaulated template content.
      def render(template, context=nil)
        render_template(load_template(template), context)
      end

      # Renders a "DO NOT EDIT" notice for placement in generated files.
      #
      # @param [Hash] options Options hash.
      # @option options [String] :message An optional message to display in the notice.
      # @option options [String] :char The comment character; defaults to '#'.
      #
      # @return [String] The rendered noticed.
      def do_not_edit_notice(options={})
        message = options[:message]
        char    = (options[:char] || '#')
        notice  = Array.new

        notice << char
        notice << "#{char} WARNING: AUTOMATICALLY GENERATED FILE; DO NOT EDIT!"
        notice << char
        notice << "#{char} #{message}" if !message.nil?
        notice << char
        notice << "#{char} Generated @ #{Time.now.utc}"
        notice << char

        notice.join("\n")
      end


    private

      # Loads the template files contents.
      def load_template(template)
        IO.read(template).chomp
      end

      # Renders the template through Erubis.
      def render_template(template, context={})
        Erubis::Eruby.new(template).evaluate(context)
      end

    end

  end

end
