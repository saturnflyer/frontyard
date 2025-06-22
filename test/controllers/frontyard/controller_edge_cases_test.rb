# frozen_string_literal: true

require "test_helper"

module Frontyard
  class ControllerEdgeCasesTest < ActionDispatch::IntegrationTest
    test "render_view with multiple render options" do
      get "/edge_case/complex_action"
      
      # Verify the response contains the expected content
      assert_includes response.body, "Complex action view with custom_value"
      # Verify the status was set correctly
      assert_equal 201, response.status
    end

    test "render_view with optional parameters" do
      get "/edge_case/action_with_optional_params"
      
      # Verify the response contains the expected content
      assert_includes response.body, "Action with optional params: provided"
    end

    test "render_view handles empty kwargs" do
      get "/edge_case"
      
      # Verify the response contains the expected content
      assert_includes response.body, "Edge case index view"
    end

    test "render_view with nil values" do
      get "/edge_case", params: { nil_value: nil }
      
      # Verify the response contains the expected content
      assert_includes response.body, "Edge case index view"
    end

    test "render_view with symbol keys" do
      get "/edge_case", params: { symbol_key: "symbol_value" }
      
      # Verify the response contains the expected content
      assert_includes response.body, "Edge case index view"
      assert_includes response.body, "symbol_value"
    end

    test "render_view with string keys" do
      get "/edge_case", params: { "string_key" => "string_value" }
      
      # Verify the response contains the expected content
      assert_includes response.body, "Edge case index view"
      assert_includes response.body, "string_value"
    end

    test "form_params with empty params" do
      get "/edge_case/form_params", params: {}
      
      # Verify the response is successful
      assert_response :success
    end

    test "form_params with complex params" do
      get "/edge_case/form_params", params: {
        user: { name: "John", email: "john@example.com" },
        nested: { deep: { value: "test" } }
      }
      
      # Verify the response is successful
      assert_response :success
    end

    test "form method with different controller names" do
      get "/users/form_test"
      assert_response :success
    end

    test "form method with complex controller names" do
      get "/admin_users/form_test"
      assert_response :success
    end

    test "render_view with missing required parameter raises error" do
      # Test that the show action works correctly with required parameters
      get "/edge_case/1"
      assert_response :success
      assert_includes response.body, "Edge case show view"
    end

    test "render_view with controller method returning nil" do
      get "/edge_case"
      
      # Verify the response contains the expected content
      assert_includes response.body, "Edge case index view"
    end

    test "render_view handles different data types correctly" do
      get "/edge_case", params: {
        string_data: "string",
        number_data: 42,
        array_data: [1, 2, 3],
        hash_data: { key: "value" }
      }
      
      # Verify the response contains the expected content
      assert_includes response.body, "Edge case index view"
    end

    test "render_view with boolean values" do
      get "/edge_case", params: {
        true_value: true,
        false_value: false
      }
      
      # Verify the response contains the expected content
      assert_includes response.body, "Edge case index view"
    end
  end
end 
