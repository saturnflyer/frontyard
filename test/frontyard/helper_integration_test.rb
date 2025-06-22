require "test_helper"

describe "Helper Integration" do
  it "ensures all components have required helpers" do
    # Test ApplicationComponent helpers
    assert_includes Frontyard::ApplicationComponent.included_modules, Phlex::Rails::Helpers::Routes
    assert_includes Frontyard::ApplicationComponent.included_modules, Phlex::Rails::Helpers::DOMID
    assert_includes Frontyard::ApplicationComponent.included_modules, Phlex::Rails::Helpers::LinkTo
    
    # Test ApplicationView helpers
    assert_includes Frontyard::ApplicationView.included_modules, Phlex::Rails::Helpers::ContentFor
    
    # Test InputComponent helpers (if available)
    # assert_includes Frontyard::InputComponent.included_modules, Phlex::Rails::Helpers::FormWith
  end
end 
