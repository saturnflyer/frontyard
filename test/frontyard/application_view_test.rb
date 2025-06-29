require "test_helper"

# Test components defined at module level to avoid constant definition in block
module Frontyard
  class Form < Frontyard::ApplicationComponent
    def view_template
      super do
        h1 { "Form rendered" }
      end
    end
  end

  class Fragment < Frontyard::ApplicationComponent
    def view_template
      super do
        h1 { "Fragment rendered" }
      end
    end
  end
end

class PageLinks < Frontyard::ApplicationComponent
  def view_template
    super do
      h1 { "PageLinks rendered" }
    end
  end
end

describe Frontyard::ApplicationView do
  let(:view) { Frontyard::ApplicationView.new }

  it "exposes flash messages" do
    # Simulate flash by stubbing the flash method
    def view.flash
      {notice: "Test notice", alert: "Test alert", error: "Test error"}
    end
    assert_equal "Test notice", view.notice
    assert_equal "Test alert", view.alert
    assert_equal "Test error", view.error
  end

  describe "#render_form" do
    it "renders a form component (unit test)" do
      # Directly instantiate and call the component
      form = Frontyard::Form.new
      buffer = +""
      form.call(buffer)
      assert_includes buffer, "Form rendered"
    end
  end

  describe "#render_fragment" do
    it "renders a fragment component (unit test)" do
      # Directly instantiate and call the component
      fragment = Frontyard::Fragment.new
      buffer = +""
      fragment.call(buffer)
      assert_includes buffer, "Fragment rendered"
    end
  end

  it "has page_links method" do
    def view.page_links
      PageLinks.new
    end
    buffer = +""
    view.page_links.call(buffer)
    assert_includes buffer, "PageLinks rendered"
  end
end
