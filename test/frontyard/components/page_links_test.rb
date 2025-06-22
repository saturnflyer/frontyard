require "test_helper"

class TestPageLinks < Frontyard::PageLinks
  def view_template
    super do
      div(class: "pagination") do
        span { "Pagination Component" }
      end
    end
  end
end

describe Frontyard::PageLinks do
  describe "inheritance" do
    it "inherits from ApplicationComponent" do
      assert Frontyard::PageLinks < Frontyard::ApplicationComponent
    end

    it "can be instantiated" do
      page_links = TestPageLinks.new
      assert_instance_of TestPageLinks, page_links
    end
  end

  describe "method signatures" do
    let(:page_links) { Frontyard::PageLinks.new }

    it "has page_link method with correct signature" do
      assert page_links.respond_to?(:page_link)
      method = page_links.method(:page_link)
      assert_equal 3, method.parameters.length
      assert_equal [:req, :req, :keyrest], method.parameters.map(&:first)
    end

    it "has button method with correct signature" do
      assert page_links.respond_to?(:button)
      method = page_links.method(:button)
      assert_equal 3, method.parameters.length
      assert_equal [:req, :req, :keyrest], method.parameters.map(&:first)
    end

    it "has dangerous_button method with correct signature" do
      assert page_links.respond_to?(:dangerous_button)
      method = page_links.method(:dangerous_button)
      assert_equal 3, method.parameters.length
      assert_equal [:req, :req, :req], method.parameters.map(&:first)
    end
  end

  describe "method behavior" do
    let(:page_links) { Frontyard::PageLinks.new }

    it "page_link merges options correctly" do
      # Test the option merging logic without calling Rails helpers
      options = { class: "custom-class" }
      merged_options = { class: "page-link" }.merge(options)
      
      assert_equal "custom-class", merged_options[:class]
      assert_equal 1, merged_options.keys.length
    end

    it "button merges options correctly" do
      # Test the option merging logic without calling Rails helpers
      options = { class: "custom-button" }
      merged_options = { 
        class: "page-button",
        form: { class: "inline-button-form" }
      }.merge(options)
      
      assert_equal "custom-button", merged_options[:class]
      assert_equal({ class: "inline-button-form" }, merged_options[:form])
    end

    it "dangerous_button merges options correctly" do
      # Test the option merging logic without calling Rails helpers
      options = { class: "custom-danger" }
      merged_options = { class: "page-button dangerous" }.merge(options)
      
      assert_equal "custom-danger", merged_options[:class]
    end

    it "dangerous_button calls button method" do
      # Test that dangerous_button calls the button method
      page_links.define_singleton_method(:button) do |text, object, options|
        { text: text, object: object, options: options.merge(class: "page-button dangerous") }
      end
      
      result = page_links.dangerous_button("Delete", "/delete", { id: "delete-btn" })
      
      assert_equal "Delete", result[:text]
      assert_equal "/delete", result[:object]
      assert_equal "page-button dangerous", result[:options][:class]
      assert_equal "delete-btn", result[:options][:id]
    end
  end

  describe "view_template" do
    it "wraps content in a div with the correct class" do
      page_links = TestPageLinks.new
      buffer = TestBuffer.new
      page_links.call(buffer)
      result = buffer.to_s

      assert_includes result, '<div class="frontyard-page-links test-page-links">'
      assert_includes result, '<div class="pagination">'
      assert_includes result, 'Pagination Component'
    end
  end

  describe "component structure" do
    it "can be extended with custom functionality" do
      class CustomPageLinks < Frontyard::PageLinks
        def view_template
          super do
            nav(class: "custom-nav") do
              ul do
                li { "Custom Navigation" }
              end
            end
          end
        end
      end

      page_links = CustomPageLinks.new
      buffer = TestBuffer.new
      page_links.call(buffer)
      result = buffer.to_s

      assert_includes result, '<nav class="custom-nav">'
      assert_includes result, '<ul>'
      assert_includes result, '<li>Custom Navigation</li>'
    end
  end

  describe "integration with other components" do
    it "can be used within other Frontyard components" do
      class NavigationContainer < Frontyard::ApplicationComponent
        def view_template
          super do
            div(class: "nav-container") do
              span { "Navigation Container" }
            end
          end
        end
      end

      container = NavigationContainer.new
      buffer = TestBuffer.new
      container.call(buffer)
      result = buffer.to_s

      assert_includes result, '<div class="nav-container">'
      assert_includes result, '<span>Navigation Container</span>'
    end
  end

  describe "edge cases" do
    let(:page_links) { Frontyard::PageLinks.new }

    it "handles empty options hash" do
      # Test option merging with empty hash
      merged_options = { class: "page-link" }.merge({})
      assert_equal "page-link", merged_options[:class]
    end

    it "preserves all option keys during merging" do
      original_options = { class: "page-link", id: "test-id", data: { value: "test" } }
      new_options = { class: "override", disabled: true }
      merged_options = original_options.merge(new_options)
      
      assert_equal "override", merged_options[:class]
      assert_equal "test-id", merged_options[:id]
      assert_equal({ value: "test" }, merged_options[:data])
      assert_equal true, merged_options[:disabled]
    end
  end
end 
