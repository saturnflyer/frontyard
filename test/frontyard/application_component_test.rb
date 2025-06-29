require "test_helper"

module Frontyard
  class Widget; end
  class CustomWidget; end
  class WidgetsTable < Frontyard::ApplicationComponent
    def initialize(data:); @data = data; end
    def view_template; super { h1 { "Table with #{@data}" } }; end
  end
  class TestTable < Frontyard::ApplicationComponent
    def initialize(data:); @data = data; end
    def view_template; super { h1 { "Default Table" } }; end
  end
  class CustomWidgetComponent < Frontyard::ApplicationComponent
    def initialize(widget:); @widget = widget; end
    def view_template; super { h1 { "Custom #{@widget.class.name}" } }; end
  end
  class WidgetsComponent < Frontyard::ApplicationComponent
    def initialize(widget:); @widget = widget; end
    def view_template; super { h1 { @widget.class.name } }; end
  end
end

class TestComponent < Frontyard::ApplicationComponent
  def view_template
    super do
      h1 { "Hello" }
    end
  end
end

class TestComponentWithConfig < Frontyard::ApplicationComponent
  configure class: "custom-class", data: { test: "value" }
  
  def view_template
    super do
      h1(**self.class.config) { "Configured" }
    end
  end
end

class TestComponentWithInitialize < Frontyard::ApplicationComponent
  initialize_with :title, :content, optional: nil
end

class TestComponentWithModel < Frontyard::ApplicationComponent
  def view_template
    super do
      render_model something: @value
    end
  end
end

class TestComponentWithTable < Frontyard::ApplicationComponent
  def view_template
    super do
      render_table from: "widgets", data: @data
    end
  end
end

describe Frontyard::ApplicationComponent do
  describe ".default_config" do
    it "returns a config object" do
      config = Frontyard::ApplicationComponent.default_config
      assert_kind_of Contours::BlendedHash, config
    end

    it "includes default class" do
      config = Frontyard::ApplicationComponent.default_config
      assert_equal "", config[:class]
    end
  end

  describe ".generate_css_class" do
    it "generates correct CSS class for ApplicationComponent" do
      assert_equal "", Frontyard::ApplicationComponent.generate_css_class
    end

    it "generates correct CSS class for subclasses" do
      assert_equal "test-component", TestComponent.generate_css_class
    end

    it "generates correct CSS class for nested classes" do
      module Frontyard
        class NestedTestComponent < ApplicationComponent; end
      end
      assert_equal "frontyard-nested-test-component", Frontyard::NestedTestComponent.generate_css_class
    end

    it "handles Frontyard namespace classes correctly" do
      module Frontyard
        class SpecialComponent < ApplicationComponent; end
      end
      assert_equal "frontyard-special-component", Frontyard::SpecialComponent.generate_css_class
    end
  end

  describe ".configure" do
    it "applies configuration to rendered output" do
      component = TestComponentWithConfig.new
      buffer = TestBuffer.new
      component.call(buffer)
      result = buffer.to_s
      assert_includes result, 'class="custom-class"'
      assert_includes result, 'data-test="value"'
    end
  end

  describe ".initialize_with" do
    let(:component_class) do
      Class.new(Frontyard::ApplicationComponent) do
        initialize_with :title, :content, optional: nil
      end
    end
    
    it "sets up accessors" do
      instance = component_class.new(title: "Hello", content: "World", optional: "Value")
      assert_equal "Hello", instance.title
      assert_equal "World", instance.content
      assert_equal "Value", instance.optional
    end
    
    it "accepts options" do
      custom_instance = component_class.new(title: "Hello", content: "World", data: { value: 123 })
      assert_includes custom_instance.options.keys, :data
      assert_equal({ value: 123 }, custom_instance.options[:data])
    end

    it "sets default values for optional parameters" do
      instance = component_class.new(title: "Hello", content: "World")
      assert_nil instance.optional
    end

    it "handles flash and html_options" do
      instance = component_class.new(
        title: "Hello", 
        content: "World",
        flash: { notice: "Success" },
        html_options: { class: "custom" }
      )
      assert_equal({ notice: "Success" }, instance.flash)
      assert_equal({ class: "custom" }, instance.html_options)
    end

    it "allows class-level configuration with blocks" do
      configured_class = Class.new(Frontyard::ApplicationComponent) do
        initialize_with :title, :content do
          # This block gets executed inside the initialize method
          # Set additional instance variables
          @processed_title = title.upcase
          @word_count = content.split.length
          @initialized_at = Time.now
        end
      end
      
      instance = configured_class.new(title: "Hello", content: "World of Rails")
      
      # The instance should have the additional instance variables set by the block
      assert_equal "HELLO", instance.instance_variable_get(:@processed_title)
      assert_equal 3, instance.instance_variable_get(:@word_count)
      assert_kind_of Time, instance.instance_variable_get(:@initialized_at)
    end
  end

  describe "#html_options" do
    it "returns the component's html options" do
      component = TestComponent.new
      assert_equal TestComponent.default_config, component.html_options
    end

    it "memoizes the html options" do
      component = TestComponent.new
      first_call = component.html_options
      second_call = component.html_options
      assert_same first_call, second_call
    end
  end

  describe "#namespace" do
    it "returns the correct namespace" do
      component = TestComponent.new
      # TestComponent is defined at the top level, so its namespace should be Object
      assert_equal Object, component.namespace
    end

    it "memoizes the namespace" do
      component = TestComponent.new
      first_call = component.namespace
      second_call = component.namespace
      assert_same first_call, second_call
    end
  end

  describe "#render_model" do
    it "renders a model with the correct component" do
      instance = Frontyard::WidgetsComponent.new(widget: Frontyard::Widget.new)
      buffer = TestBuffer.new
      instance.call(buffer)
      html = buffer.to_s
      assert_includes html, '<h1>Frontyard::Widget</h1>'
    end
    it "renders with custom from parameter" do
      component = TestComponentWithModel.new
      component.instance_variable_set(:@value, Frontyard::Widget.new)
      rendered_component = nil
      component.define_singleton_method(:render) do |comp|
        rendered_component = comp
        ""
      end
      component.render_model(from: "frontyard/custom_widget_component", widget: Frontyard::Widget.new)
      assert_kind_of Frontyard::CustomWidgetComponent, rendered_component
    end
  end

  describe "#render_table" do
    it "renders a table component" do
      component = TestComponentWithTable.new
      component.instance_variable_set(:@data, "test data")
      rendered_component = nil
      component.define_singleton_method(:render) do |comp|
        rendered_component = comp
        ""
      end
      component.render_table(from: "frontyard/widgets_table", data: "test data")
      assert_kind_of Frontyard::WidgetsTable, rendered_component
    end
    it "renders with default table class" do
      component = TestComponentWithTable.new
      component.instance_variable_set(:@data, "test data")
      rendered_component = nil
      component.define_singleton_method(:render) do |comp|
        rendered_component = comp
        ""
      end
      component.render_table(data: "test data")
      assert_kind_of Frontyard::TestTable, rendered_component
    end
  end

  describe "#params" do
    it "delegates to helpers.params" do
      component = TestComponent.new
      mock_params = { id: 1 }
      component.define_singleton_method(:helpers) do
        mock_helpers = Object.new
        def mock_helpers.params
          { id: 1 }
        end
        mock_helpers
      end
      assert_equal mock_params, component.params
    end
  end

  describe "#view_template" do
    it "wraps content in a div with the correct class" do
      component = TestComponent.new
      buffer = TestBuffer.new
      component.call(buffer)
      result = buffer.to_s
      assert_includes result, '<div class="test-component">'
      assert_includes result, '<h1>Hello</h1>'
    end
    it "uses configured html options" do
      component = TestComponentWithConfig.new
      buffer = TestBuffer.new
      component.call(buffer)
      result = buffer.to_s
      assert_includes result, '<div class="custom-class"'
      assert_includes result, 'data-test="value"'
    end
  end

  describe "development environment behavior" do
    it "adds comments in development" do
      Rails.env.stub :development?, true do
        component = TestComponent.new
        buffer = TestBuffer.new
        component.call(buffer)
        result = buffer.to_s
        assert_includes result, "<!-- Before TestComponent -->"
      end
    end
    it "does not add comments in other environments" do
      Rails.env.stub :development?, false do
        component = TestComponent.new
        buffer = TestBuffer.new
        component.call(buffer)
        result = buffer.to_s
        refute_includes result, "<!-- Before TestComponent -->"
      end
    end
  end
end 
