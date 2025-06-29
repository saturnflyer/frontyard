# frozen_string_literal: true

require "test_helper"

# Test components for Actions testing
class DefaultActionsTestComponent < Frontyard::Actions
  def view_template
    super
  end
end

class CustomActionsTestComponent < Frontyard::Actions
  configure(class: "custom-actions")

  def view_template
    super do
      button(type: "submit", class: "btn-primary") { "Save" }
      button(type: "button", class: "btn-secondary") { "Preview" }
    end
  end
end

class MixedActionsTestComponent < Frontyard::Actions
  def view_template
    super do
      button(type: "submit") { "Create" }
      button(type: "reset") { "Clear" }
    end
  end
end

class EmptyBlockActionsTestComponent < Frontyard::Actions
  def view_template
    super do
      # Empty block
    end
  end
end

class MultipleButtonsActionsTestComponent < Frontyard::Actions
  def view_template
    super do
      button(type: "submit", class: "btn-primary") { "Save" }
      button(type: "button", class: "btn-secondary") { "Cancel" }
      button(type: "button", class: "btn-danger") { "Delete" }
    end
  end
end

describe Frontyard::Actions do
  let(:component) { Frontyard::Actions.new }

  it "has the correct css class" do
    buffer = +""
    component.call(buffer)
    result = buffer
    assert_includes result, "frontyard-actions"
  end

  describe "default behavior (no block given)" do
    it "renders default form action buttons" do
      buffer = +""
      DefaultActionsTestComponent.new.call(buffer)
      result = buffer

      assert_includes result, 'class="frontyard-actions default-actions-test-component"'

      assert_includes result, 'type="submit"'
      assert_includes result, "Submit"
      assert_includes result, 'type="cancel"'
      assert_includes result, "Cancel"
    end

    it "renders all three default buttons in correct order" do
      buffer = +""
      DefaultActionsTestComponent.new.call(buffer)
      result = buffer

      # Check that all three buttons are present
      submit_index = result.index('type="submit"')
      cancel_index = result.index('type="cancel"')

      assert submit_index, "Submit button should be present"
      assert cancel_index, "Cancel button should be present"

      # Check order: Submit, Cancel
      assert submit_index < cancel_index, "Submit should come before Cancel"
    end
  end

  describe "custom behavior (with block given)" do
    it "renders custom form action buttons from block" do
      buffer = +""
      CustomActionsTestComponent.new.call(buffer)
      result = buffer

      assert_includes result, 'class="custom-actions"'

      assert_includes result, 'type="submit"'
      assert_includes result, 'class="btn-primary"'
      assert_includes result, "Save"
      assert_includes result, 'type="button"'
      assert_includes result, 'class="btn-secondary"'
      assert_includes result, "Preview"

      # Should NOT render default buttons
      refute_includes result, "Reset"
      refute_includes result, "Cancel"
    end

    it "renders custom buttons in the order provided in block" do
      buffer = +""
      CustomActionsTestComponent.new.call(buffer)
      result = buffer

      save_index = result.index("Save")
      preview_index = result.index("Preview")

      assert save_index, "Save button should be present"
      assert preview_index, "Preview button should be present"

      # Check order: Save, Preview
      assert save_index < preview_index, "Save should come before Preview"
    end
  end

  describe "mixed behavior" do
    it "renders only custom content when block is provided" do
      buffer = +""
      MixedActionsTestComponent.new.call(buffer)
      result = buffer

      assert_includes result, 'class="frontyard-actions mixed-actions-test-component"'

      assert_includes result, "Create"
      assert_includes result, "Clear"

      # Should NOT render default buttons (block takes precedence)
      refute_includes result, "Submit"
      refute_includes result, "Reset"
      refute_includes result, "Cancel"
    end
  end

  describe "HTML structure" do
    it "renders proper HTML structure with frontyard-actions wrapper" do
      buffer = +""
      DefaultActionsTestComponent.new.call(buffer)
      result = buffer

      # Should start with a div with frontyard-actions class
      assert_match(/<div class="frontyard-actions default-actions-test-component">/, result)

      # Should contain button elements
      assert_includes result, "<button"
      assert_includes result, "</button>"

      # Should end with closing div
      assert_includes result, "</div>"
    end

    it "renders buttons with proper attributes" do
      buffer = +""
      DefaultActionsTestComponent.new.call(buffer)
      result = buffer

      assert_match(/<button[^>]*type="submit"[^>]*>Submit<\/button>/, result)
      assert_match(/<button[^>]*type="cancel"[^>]*>Cancel<\/button>/, result)
    end
  end

  describe "accessibility" do
    it "renders buttons with proper semantic types" do
      buffer = +""
      DefaultActionsTestComponent.new.call(buffer)
      result = buffer

      assert_includes result, 'type="submit"'
      assert_includes result, 'type="cancel"'
    end
  end

  describe "integration with ApplicationForm" do
    it "can be instantiated and has form_actions method" do
      # Test that the component can be instantiated
      form_component = Frontyard::ApplicationForm.new
      assert form_component.respond_to?(:form_actions), "ApplicationForm should have form_actions method"
    end
  end

  describe "direct component usage" do
    it "renders default buttons when called directly without block" do
      buffer = +""
      Frontyard::Actions.new.call(buffer)
      result = buffer

      assert_includes result, 'class="frontyard-actions"'
      assert_includes result, "Submit"
      assert_includes result, "Cancel"
    end
  end

  describe "edge cases" do
    it "handles empty block gracefully" do
      buffer = +""
      EmptyBlockActionsTestComponent.new.call(buffer)
      result = buffer

      assert_includes result, 'class="frontyard-actions empty-block-actions-test-component"'
      assert_match(/<div class="frontyard-actions empty-block-actions-test-component"><\/div>/, result)
    end

    it "handles multiple buttons in block" do
      buffer = +""
      MultipleButtonsActionsTestComponent.new.call(buffer)
      result = buffer

      assert_includes result, "Save"
      assert_includes result, "Cancel"
      assert_includes result, "Delete"
      refute_includes result, "Submit"
      refute_includes result, "Reset"
    end
  end
end
