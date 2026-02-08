require "test_helper"

describe Frontyard do
  describe "module structure" do
    it "is a module" do
      assert_kind_of Module, Frontyard
    end

    it "has the expected constants" do
      assert defined?(Frontyard::ApplicationComponent)
      assert defined?(Frontyard::ApplicationView)
      assert defined?(Frontyard::ApplicationTable)
      assert defined?(Frontyard::Field)
      assert defined?(Frontyard::PageLinks)
    end

    it "can be included in other modules" do
      test_module = Module.new
      test_module.include Frontyard
      assert test_module.included_modules.include?(Frontyard)
    end

    it "provides a namespace for components" do
      assert Frontyard::ApplicationComponent < Phlex::HTML
      assert Frontyard::ApplicationView < Phlex::HTML
      assert Frontyard::ApplicationTable < Frontyard::ApplicationComponent
      assert Frontyard::Field < Frontyard::ApplicationComponent
      assert Frontyard::PageLinks < Frontyard::ApplicationComponent
    end
  end

  describe "component inheritance" do
    it "allows components to inherit from ApplicationComponent" do
      test_component = Class.new(Frontyard::ApplicationComponent) do
        def view_template
          div { "Test" }
        end
      end

      component = test_component.new
      buffer = TestBuffer.new
      component.call(buffer)
      result = buffer.to_s

      assert_includes result, "<div>"
      assert_includes result, "Test"
    end

    it "allows views to inherit from ApplicationView" do
      test_view = Class.new(Frontyard::ApplicationView) do
        def view_template
          div { "View Test" }
        end
      end

      view = test_view.new
      buffer = TestBuffer.new
      view.call(buffer)
      result = buffer.to_s

      assert_includes result, "<div>"
      assert_includes result, "View Test"
    end
  end

  describe "component instantiation" do
    it "can instantiate ApplicationComponent subclasses" do
      test_component = Class.new(Frontyard::ApplicationComponent) do
        def view_template
          span { "Instantiated" }
        end
      end

      instance = test_component.new
      assert_instance_of test_component, instance
    end

    it "can instantiate ApplicationView subclasses" do
      test_view = Class.new(Frontyard::ApplicationView) do
        def view_template
          span { "View Instance" }
        end
      end

      instance = test_view.new
      assert_instance_of test_view, instance
    end
  end

  describe "initialize_with" do
    it "accepts string values as defaults" do
      test_component = Class.new(Frontyard::ApplicationComponent) do
        initialize_with title: "Default Title"

        def view_template
          div { title }
        end
      end

      component = test_component.new
      expect(component.title).must_equal "Default Title"
    end
  end

  describe "component rendering" do
    it "renders components with proper HTML structure" do
      test_component = Class.new(Frontyard::ApplicationComponent) do
        def view_template
          div(class: "test-component") do
            h1 { "Title" }
            p { "Content" }
          end
        end
      end

      component = test_component.new
      buffer = TestBuffer.new
      component.call(buffer)
      result = buffer.to_s

      assert_includes result, '<div class="test-component">'
      assert_includes result, "<h1>Title</h1>"
      assert_includes result, "<p>Content</p>"
    end

    it "renders views with proper HTML structure" do
      test_view = Class.new(Frontyard::ApplicationView) do
        def view_template
          div(class: "test-view") do
            h2 { "View Title" }
            p { "View Content" }
          end
        end
      end

      view = test_view.new
      buffer = TestBuffer.new
      view.call(buffer)
      result = buffer.to_s

      assert_includes result, '<div class="test-view">'
      assert_includes result, "<h2>View Title</h2>"
      assert_includes result, "<p>View Content</p>"
    end
  end
end
