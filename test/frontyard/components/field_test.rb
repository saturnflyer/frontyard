require "test_helper"

class TestField < Frontyard::Field
  def view_template
    div(**self.class.config) do
      # Test basic HTML rendering without Rails helpers
      div(class: "field-container") do
        span { "Field Content" }
      end
    end
  end

  # Ensure we inherit the config from Frontyard::Field
  def self.config
    superclass.config
  end
end

describe Frontyard::Field do
  describe "inheritance" do
    it "inherits from ApplicationComponent" do
      assert Frontyard::Field < Frontyard::ApplicationComponent
    end

    it "can be instantiated" do
      field = TestField.new(object: "test", attribute: "to_s")
      assert_instance_of TestField, field
    end
  end

  describe "included modules" do
    let(:field) { TestField.new(object: "test", attribute: "to_s") }

    it "includes FormWith helper" do
      assert field.respond_to?(:form_with)
    end

    it "includes Label helper" do
      assert field.respond_to?(:label)
    end

    it "includes Pluralize helper" do
      assert field.respond_to?(:pluralize)
    end

    it "includes TextField helper" do
      assert field.respond_to?(:text_field)
    end

    it "includes NumberField helper" do
      assert field.respond_to?(:number_field)
    end

    it "includes CheckBox helper" do
      assert field.respond_to?(:check_box)
    end

    it "includes DateSelect helper" do
      assert field.respond_to?(:date_select)
    end

    it "includes OptionsForSelect helper" do
      assert field.respond_to?(:options_for_select)
    end

    it "includes Select helper" do
      assert field.respond_to?(:select)
    end
  end

  describe "view_template" do
    it "wraps content in a div with the correct class" do
      field = TestField.new(object: "test", attribute: "to_s")
      buffer = TestBuffer.new
      field.call(buffer)
      result = buffer.to_s

      assert_includes result, '<div class="frontyard-field">'
      assert_includes result, '<div class="field-container">'
      assert_includes result, 'Field Content'
    end
  end

  describe "module inclusion verification" do
    it "has all required Phlex::Rails::Helpers modules" do
      field = TestField.new(object: "test", attribute: "to_s")
      
      # Check that the field includes all the expected helper modules
      included_modules = field.class.included_modules.map(&:to_s)
      
      assert_includes included_modules, "Phlex::Rails::Helpers::FormWith"
      assert_includes included_modules, "Phlex::Rails::Helpers::Label"
      assert_includes included_modules, "Phlex::Rails::Helpers::Pluralize"
      assert_includes included_modules, "Phlex::Rails::Helpers::TextField"
      assert_includes included_modules, "Phlex::Rails::Helpers::NumberField"
      assert_includes included_modules, "Phlex::Rails::Helpers::Checkbox"
      assert_includes included_modules, "Phlex::Rails::Helpers::DateSelect"
      assert_includes included_modules, "Phlex::Rails::Helpers::OptionsForSelect"
      assert_includes included_modules, "Phlex::Rails::Helpers::Select"
    end
  end

  describe "component structure" do
    it "can be extended with custom functionality" do
      class CustomField < Frontyard::Field
        def view_template
          super do
            div(class: "custom-field") do
              span { "Custom Label" }
              span { "Custom Input" }
            end
          end
        end
      end

      field = CustomField.new(object: "test", attribute: "to_s")
      buffer = TestBuffer.new
      field.call(buffer)
      result = buffer.to_s

      assert_includes result, '<div class="custom-field">'
      assert_includes result, '<span>Custom Label</span>'
      assert_includes result, '<span>Custom Input</span>'
    end
  end

  describe "integration with other components" do
    it "can be used within other Frontyard components" do
      class FormContainer < Frontyard::ApplicationComponent
        def view_template
          super do
            div(class: "form-container") do
              span { "Form Container" }
            end
          end
        end
      end

      container = FormContainer.new
      buffer = TestBuffer.new
      container.call(buffer)
      result = buffer.to_s

      assert_includes result, '<div class="form-container">'
      assert_includes result, '<span>Form Container</span>'
    end
  end
end 
