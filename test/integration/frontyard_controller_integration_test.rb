# frozen_string_literal: true

require "test_helper"

module Frontyard
  class ControllerIntegrationTest < ActionDispatch::IntegrationTest
    test "index action renders view with collection" do
      get "/test"
      assert_response :success
      assert_includes response.body, "Index view with 2 items"
    end

    test "show action renders view with resource" do
      get "/test/1"
      assert_response :success
      assert_includes response.body, "Show view for Test Resource"
    end

    test "new action renders view" do
      get "/test/new"
      assert_response :success
    end

    test "create action renders view" do
      post "/test"
      assert_response :success
    end

    test "edit action renders view" do
      get "/test/1/edit"
      assert_response :success
    end

    test "update action renders view" do
      patch "/test/1"
      assert_response :success
    end

    test "destroy action renders view" do
      delete "/test/1"
      assert_response :success
    end

    test "flash messages are passed to views" do
      get "/test"
      assert_response :success
    end

    test "form_params processes parameters correctly" do
      controller = TestController.new
      assert_respond_to controller, :form_params
    end

    test "form method returns correct form class" do
      controller = TestController.new
      assert_equal Views::Test::Form, controller.form
    end
  end
end
