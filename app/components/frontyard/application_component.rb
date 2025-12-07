# frozen_string_literal: true

module Frontyard
  class ApplicationComponent < Phlex::HTML
    include Phlex::Rails::Helpers::Routes
    include Phlex::Rails::Helpers::DOMID
    include Phlex::Rails::Helpers::LinkTo
    include Phlex::Rails::Helpers::ButtonTo

    class << self
      def default_config
        @default_config ||= Config.init(
          class: generate_css_class
        )
      end

      def generate_css_class
        return "" if name == "Frontyard::ApplicationComponent"
        class_name = name
        if class_name.to_s.start_with?("Frontyard::") && class_name.to_s != "Frontyard::ApplicationComponent"
          return class_name.split("::").map { |part| part.gsub(/([A-Z])/, '-\1').downcase.sub(/^-/, "") }.join("-")
        end
        return "frontyard-component" if class_name.nil? || class_name.start_with?("#<")
        this_css_class = class_name.split("::").last.gsub(/([A-Z])/, '-\1').downcase.sub(/^-/, "")
        if superclass.respond_to?(:generate_css_class)
          css_class = Contours::StructuredString.new(superclass.generate_css_class)
          css_class << this_css_class
        else
          this_css_class
        end.to_s
      end

      def config
        @config ||= default_config
      end

      private

      def configure(**kwargs)
        @config = Config.init(kwargs)
      end
    end

    def before_template
      if Rails.env.development?
        comment { "Before #{self.class.name}" }
      end
      super
    end

    def html_options
      @html_options || self.class.config
    end

    def namespace = @namespace ||= begin
      ns = self.class.name.deconstantize
      ns.empty? ? Object : Object.const_get(ns)
    end

    # Define an initialize method along with attr_accessors
    #
    # Example:
    #   initialize_with :some, :keyword, optional: nil
    #   initialize_with :some, :keyword, optional: nil do
    #     @processed_data = some.upcase
    #   end
    def self.initialize_with(*keys, **kwargs, &block)
      mod = Module.new
      tokens = keys.map do |key|
        [
          "#{key}:",
          "@#{key} = #{key}"
        ]
      end.to_h
      kwargs.each do |key, value|
        value ||= "nil"
        tokens["#{key}: #{value}"] = "@#{key} = #{key}"
      end
      accessors = keys + kwargs.keys
      keyword_args = tokens.keys
      ivars = tokens.values

      # Include the block code in the initialize method if provided
      block_code = if block_given?
        # Convert the block to a string representation that can be executed
        # This is a simplified approach - in practice you might want to use a more robust method
        "instance_eval(&self.class.instance_variable_get(:@initialize_block))"
      else
        ""
      end

      mod.class_eval <<~RUBY, __FILE__, __LINE__ + 1
        def initialize(#{keyword_args.join(", ")}, **options, &block)
          #{ivars.join("\n")}
          @flash = options.delete(:flash) || {}
          if options.key?(:html_options)
            @html_options = options.delete(:html_options)
          end
          @options = options
          yield self if block_given?
          #{block_code}
        end
      RUBY
      accessors += [:flash, :options, :html_options]
      attr_accessor(*accessors)
      const_set(:Initializer, mod)
      include mod

      # Store the block for execution on instances
      @initialize_block = block if block_given?
    end

    # Helper to filter kwargs for a class's initialize method
    private def filter_kwargs_for(klass, kwargs)
      accepted = klass.instance_method(:initialize).parameters
        .select { |type, _| type == :key || type == :keyreq }
        .map(&:last)
      kwargs.slice(*accepted)
    end

    # Helper to safely try multiple constant names
    private def safe_const_get(*names)
      names.each do |name|
        return Object.const_get(name)
      rescue NameError
        next
      end
      raise NameError, "None of the constants found: #{names.join(", ")}"
    end

    # Rendere the partials that represent a model
    #
    # Example:
    #   render_model something: value
    #   render_model something: value, from: "widgets/widget"
    def render_model(from: nil, **kwargs)
      const_names = if from
        base = from.classify
        [base, "#{base}Component"]
      else
        namespace = self.class.name.deconstantize
        model_name = namespace.demodulize.singularize
        [
          "#{namespace}::#{model_name}",
          "#{namespace}::#{model_name}Component"
        ]
      end
      klass = safe_const_get(*const_names)
      filtered_kwargs = filter_kwargs_for(klass, kwargs)
      render klass.new(**filtered_kwargs)
    end

    # Render a table component
    #
    # Example:
    #   render_table from: "widgets/widget"
    #   render_table from: "widgets/widget", columns: [:name, :description]
    def render_table(from: nil, **kwargs, &block)
      const_names = if from
        base = from.classify
        [base, "#{base}Table"]
      elsif self.class.name.include?("::")
        # For top-level classes (no namespace), try Frontyard namespace first
        namespace = self.class.name.deconstantize
        [
          "#{namespace}::Table",
          "#{namespace}::#{self.class.name.demodulize}Table",
          "#{self.class.name}Table"
        ]
      else
        # Top-level class, try Frontyard namespace with common table names
        [
          "Frontyard::TestTable",
          "Frontyard::Table",
          "Frontyard::#{self.class.name}Table",
          "#{self.class.name}Table"
        ]
      end
      klass = safe_const_get(*const_names)
      filtered_kwargs = filter_kwargs_for(klass, kwargs)
      render klass.new(**filtered_kwargs, &block)
    end

    def params = view_context.params

    def view_template(&) = div(**html_options, &)
  end
end
