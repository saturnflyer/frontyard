# frozen_string_literal: true

require "test_helper"

# Test components for Fields testing
class TextFieldTestComponent < Frontyard::Fields
  def view_template
    field("name", type: "text", placeholder: "Enter name")
  end
end

class NumberFieldTestComponent < Frontyard::Fields
  def view_template
    field("age", type: "number", min: 0, max: 120)
  end
end

class CheckboxFieldTestComponent < Frontyard::Fields
  def view_template
    field("active", type: "checkbox", checked: true)
  end
end

class HumanizedLabelTestComponent < Frontyard::Fields
  def view_template
    field("user_email", type: "email")
  end
end

class HtmlOptionsTestComponent < Frontyard::Fields
  def view_template
    field("description", type: "textarea", class: "form-control", required: true)
  end
end

class EmptyNameTestComponent < Frontyard::Fields
  def view_template
    field("", type: "text")
  end
end

class NilOptionsTestComponent < Frontyard::Fields
  def view_template
    field("name", nil)
  end
end

class TestFieldComponent < Frontyard::Fields
  def view_template
    field("test")
  end
end

describe Frontyard::Fields do
  let(:component) { Frontyard::Fields.new }
  
  it "renders text field with default type" do
    rendered = TextFieldTestComponent.new.call
    assert_includes rendered, 'type="text"'
    assert_includes rendered, 'name="name"'
    assert_includes rendered, 'placeholder="Enter name"'
  end

  it "renders number field with attributes" do
    rendered = NumberFieldTestComponent.new.call
    assert_includes rendered, 'type="number"'
    assert_includes rendered, 'name="age"'
    assert_includes rendered, 'min="0"'
    assert_includes rendered, 'max="120"'
  end

  it "renders checkbox field" do
    rendered = CheckboxFieldTestComponent.new.call
    assert_includes rendered, 'type="checkbox"'
    assert_includes rendered, 'name="active"'
    assert_includes rendered, 'checked="true"'
  end

  it "renders humanized label" do
    rendered = HumanizedLabelTestComponent.new.call
    assert_includes rendered, "User email"
    assert_includes rendered, 'type="email"'
  end

  it "renders HTML attributes" do
    rendered = HtmlOptionsTestComponent.new.call
    assert_includes rendered, 'class="form-control"'
    assert_includes rendered, 'required="true"'
    assert_includes rendered, 'type="textarea"'
  end

  it "handles empty name gracefully" do
    rendered = EmptyNameTestComponent.new.call
    assert_includes rendered, 'name=""'
    assert_includes rendered, "frontyard-field"
  end

  it "handles nil options gracefully" do
    rendered = NilOptionsTestComponent.new.call
    assert_includes rendered, 'name="name"'
    assert_includes rendered, 'type="text"'
  end

  it "renders with proper CSS class" do
    assert_includes component.call, "frontyard-fields"
  end

  it "renders frontyard-field wrapper div" do
    rendered = TestFieldComponent.new.call
    assert_includes rendered, 'class="frontyard-field"'
  end

  it "renders label with input" do
    rendered = TestFieldComponent.new.call
    assert_includes rendered, "<label>"
    assert_includes rendered, "<input"
    assert_includes rendered, "</label>"
  end
end 
