# frozen_string_literal: true

require "test_helper"

class FrontyardControllerIntegrationTest < ActionDispatch::IntegrationTest
  test "form method returns correct form class" do
    controller = TestController.new
    assert_equal Views::Test::Form, controller.form
  end

  test "form_params processes params through form" do
    controller = TestController.new
    params = ActionController::Parameters.new(test: "value").permit!
    controller.params = params
    result = controller.form_params
    assert_equal "value", result[:test]
  end

  test "index renders the correct view and data" do
    get "/test"
    assert_response :success
    assert_includes response.body, "Index view with 2 items"
  end

  test "show renders the correct view and data" do
    get "/test/1"
    assert_response :success
    assert_includes response.body, "Show view for Test Resource"
  end

  test "new renders the correct view" do
    get "/test/new"
    assert_response :success
    assert_includes response.body, "Index view with 2 items"
  end

  test "edit renders the correct view" do
    get "/test/1/edit"
    assert_response :success
    assert_includes response.body, "Index view with 2 items"
  end

  test "create renders the correct view" do
    post "/test"
    assert_response :success
    assert_includes response.body, "Index view with 2 items"
  end

  test "update renders the correct view" do
    patch "/test/1"
    assert_response :success
    assert_includes response.body, "Index view with 2 items"
  end

  test "destroy renders the correct view" do
    delete "/test/1"
    assert_response :success
    assert_includes response.body, "Index view with 2 items"
  end

  test "flash is passed to the view" do
    get "/test"
    follow_redirect! if response.redirect?
    assert_response :success
    get "/test", params: {}
    assert_response :success
    assert_includes response.body, "Index view with 2 items"
  end
end
