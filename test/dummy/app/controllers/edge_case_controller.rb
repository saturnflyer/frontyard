# frozen_string_literal: true

class EdgeCaseController < ApplicationController
  def index
    render_view(
      symbol_key: params[:symbol_key],
      string_key: params[:string_key],
      string_data: params[:string_data],
      number_data: params[:number_data],
      array_data: params[:array_data],
      hash_data: params[:hash_data],
      true_value: params[:true_value],
      false_value: params[:false_value]
    )
  end

  def show
    render_view
  end

  def complex_action
    render_view(
      custom_data: "custom_value",
      status: :created,
      content_type: "application/json"
    )
  end

  def action_with_optional_params
    render_view(optional_param: "provided")
  end

  def form_params
    result = super
    render plain: result.inspect
  end

  private

  def custom_data
    "custom_value"
  end

  def test_collection
    item1 = Object.new
    item1.define_singleton_method(:id) { 1 }
    item1.define_singleton_method(:name) { "Item 1" }
    [item1]
  end

  def test_resource
    resource = Object.new
    resource.define_singleton_method(:id) { 1 }
    resource.define_singleton_method(:name) { "Test Resource" }
    resource
  end
end 
