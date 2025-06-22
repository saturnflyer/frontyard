require "test_helper"

# Simple buffer for testing Phlex components
class TestBuffer
  def initialize
    @output = +""
  end
  
  def <<(content)
    @output << content
  end
  
  def to_s
    @output
  end
end

# Test controller to simulate real form processing
class TestEventsController < ActionController::Base
  include Frontyard::Controller

  def create
    # Simulate the form processing that would happen in a real controller
    processed_params = form.process_params(params)
    
    # In a real app, this would be saved to a model
    render json: { 
      processed_params: processed_params,
      original_params: params.to_unsafe_h
    }
  end

  private

  def form
    TestEventForm
  end
end

# Test form class that uses the DateTimeParamTransformer
class TestEventForm < Frontyard::ApplicationForm
  def self.process_params(params)
    # Simulate processing datetime parameters
    # This returns just the converted Time object
    format_date_parts(:event, :start_time, params: params)
  end

  private

  def self.format_date_parts(*keys, params:)
    Frontyard::ApplicationForm::DateTimeParamTransformer.new(keys: keys, hash: params).call
  end
end

# Test form class for testing form_actions and field methods
class TestFormWithActions < Frontyard::ApplicationForm
  def view_template
    super do
      form_actions(class: "form-actions") do
        button { "Submit" }
      end
    end
  end
end

class TestFormWithField < Frontyard::ApplicationForm
  def view_template
    super do
      field(:name, label: "Name", required: true)
    end
  end
end

# Integration test class
class ApplicationFormIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    # Set up routes for our test controller
    Rails.application.routes.draw do
      post '/test_events', to: 'test_events#create'
    end
  end

  teardown do
    # Clean up routes
    Rails.application.routes.clear!
  end

  def test_transforms_rails_datetime_select_parameters_to_time_objects
    # Simulate the exact parameters Rails sends from datetime_select
    params = {
      event: {
        "title" => "Test Event",
        "start_time(1i)" => "2023",  # Year
        "start_time(2i)" => "10",    # Month
        "start_time(3i)" => "15",    # Day
        "start_time(4i)" => "14",    # Hour
        "start_time(5i)" => "30",    # Minute
        "start_time(6i)" => "45"     # Second
      }
    }

    # Make a POST request to simulate form submission
    post "/test_events", params: params
    
    assert_response :success
    
    # Parse JSON response
    response_data = JSON.parse(response.body)
    
    # The processed_params is serialized as an ISO string, so parse it back to Time
    start_time = Time.parse(response_data["processed_params"])
    assert_kind_of Time, start_time
    assert_equal 2023, start_time.year
    assert_equal 10, start_time.month
    assert_equal 15, start_time.day
    assert_equal 14, start_time.hour
    assert_equal 30, start_time.min
  end

  def test_handles_missing_datetime_parameters_gracefully
    # Test with incomplete datetime parameters
    params = {
      event: {
        "title" => "Test Event",
        "start_time(1i)" => "2023",
        "start_time(2i)" => "10"
        # Missing day, hour, minute, second
      }
    }

    post "/test_events", params: params
    
    assert_response :success
    
    # Parse JSON response
    response_data = JSON.parse(response.body)
    start_time = Time.parse(response_data["processed_params"])
    
    # Should still create a Time object with defaults for missing parts
    assert_kind_of Time, start_time
    assert_equal 2023, start_time.year
    assert_equal 10, start_time.month
    assert_equal 1, start_time.day  # Default to 1st of month
    assert_equal 0, start_time.hour # Default to midnight
    assert_equal 0, start_time.min  # Default to 0 minutes
  end

  def test_returns_current_time_when_no_datetime_parts_provided
    # Test with no datetime parameters at all
    params = {
      event: {
        "title" => "Test Event"
        # No datetime parts
      }
    }

    post "/test_events", params: params
    
    assert_response :success
    
    # Parse JSON response
    response_data = JSON.parse(response.body)
    start_time = Time.parse(response_data["processed_params"])
    
    # Should return current time when no parts provided
    assert_kind_of Time, start_time
    assert_in_delta Time.current, start_time, 1.second
  end
end

describe Frontyard::ApplicationForm do
  describe "inheritance" do
    it "inherits from ApplicationComponent" do
      assert Frontyard::ApplicationForm < Frontyard::ApplicationComponent
    end

    it "includes necessary Rails helpers" do
      form_class = Frontyard::ApplicationForm
      assert form_class.included_modules.include?(Phlex::Rails::Helpers::DatetimeField)
      assert form_class.included_modules.include?(Phlex::Rails::Helpers::FormWith)
      assert form_class.included_modules.include?(Phlex::Rails::Helpers::Label)
      assert form_class.included_modules.include?(Phlex::Rails::Helpers::Pluralize)
      assert form_class.included_modules.include?(Phlex::Rails::Helpers::TextField)
    end
  end

  describe "#form_actions" do
    it "renders Actions component with kwargs" do
      form = TestFormWithActions.new
      buffer = TestBuffer.new
      form.call(buffer)
      result = buffer.to_s
      assert_includes result, '<div class="frontyard-actions">'
      assert_includes result, '<button>Submit</button>'
    end

    it "passes kwargs to Actions component" do
      form = TestFormWithActions.new
      
      # Mock the render method to capture the component being rendered
      rendered_component = nil
      form.define_singleton_method(:render) do |comp|
        rendered_component = comp
        ""
      end
      
      form.form_actions(class: "custom-actions", data: { test: "value" })
      assert_kind_of Frontyard::Actions, rendered_component
    end
  end

  describe "#field" do
    it "renders Field component with arguments" do
      form = TestFormWithField.new
      buffer = TestBuffer.new
      form.call(buffer)
      result = buffer.to_s
      # The field method should render a Field component
      assert_includes result, '<div'
    end

    it "passes arguments to Field component" do
      form = TestFormWithField.new
      
      # Mock the render method to capture the component being rendered
      rendered_component = nil
      form.define_singleton_method(:render) do |comp|
        rendered_component = comp
        ""
      end
      
      form.field(:name, label: "Name", required: true)
      assert_kind_of Frontyard::Field, rendered_component
    end
  end

  describe "DateTimeParamTransformer unit tests" do
    it "transforms date parameters correctly" do
      params = {
        event: {
          "title" => "Test Event",
          "start_time(1i)" => "2023",
          "start_time(2i)" => "10",
          "start_time(3i)" => "15",
          "start_time(4i)" => "14",
          "start_time(5i)" => "30"
        }
      }
      
      transformer = Frontyard::ApplicationForm::DateTimeParamTransformer.new(
        keys: [:event, :start_time],
        hash: params
      )
      result = transformer.call
      assert_kind_of Time, result
      assert_equal 2023, result.year
      assert_equal 10, result.month
      assert_equal 15, result.day
      assert_equal 14, result.hour
      assert_equal 30, result.min
    end

    it "handles nested datetime parameters" do
      params = {
        event: {
          "title" => "Test Event",
          "schedule": {
            "start_time(1i)" => "2023",
            "start_time(2i)" => "10",
            "start_time(3i)" => "15",
            "start_time(4i)" => "14",
            "start_time(5i)" => "30"
          }
        }
      }

      # Test with nested datetime parameters
      transformer = Frontyard::ApplicationForm::DateTimeParamTransformer.new(
        keys: [:event, :schedule, :start_time],
        hash: params
      )
      result = transformer.call
      
      assert_kind_of Time, result
      assert_equal 2023, result.year
      assert_equal 10, result.month
      assert_equal 15, result.day
      assert_equal 14, result.hour
      assert_equal 30, result.min
    end

    it "provides sensible defaults for missing parts" do
      params = {
        event: {
          "start_time(1i)" => "2023",
          "start_time(2i)" => "10"
          # Missing day, hour, minute
        }
      }

      transformer = Frontyard::ApplicationForm::DateTimeParamTransformer.new(
        keys: [:event, :start_time],
        hash: params
      )
      result = transformer.call
      
      assert_kind_of Time, result
      assert_equal 2023, result.year
      assert_equal 10, result.month
      assert_equal 1, result.day    # Default to 1st
      assert_equal 0, result.hour   # Default to midnight
      assert_equal 0, result.min    # Default to 0 minutes
    end

    it "returns current time when no parts provided" do
      params = {
        event: {
          "title" => "Test Event"
          # No datetime parts at all
        }
      }

      transformer = Frontyard::ApplicationForm::DateTimeParamTransformer.new(
        keys: [:event, :start_time],
        hash: params
      )
      result = transformer.call
      
      assert_kind_of Time, result
      assert_in_delta Time.current, result, 1.second
    end

    it "handles both string and symbol keys" do
      params = {
        event: {
          "title" => "Test Event",
          :"start_time(1i)" => "2023",
          "start_time(2i)" => "10",
          :"start_time(3i)" => "15"
        }
      }

      transformer = Frontyard::ApplicationForm::DateTimeParamTransformer.new(
        keys: [:event, :start_time],
        hash: params
      )
      result = transformer.call
      
      assert_kind_of Time, result
      assert_equal 2023, result.year
      assert_equal 10, result.month
      assert_equal 15, result.day
    end

    it "removes processed parameters from hash" do
      params = {
        event: {
          "title" => "Test Event",
          "start_time(1i)" => "2023",
          "start_time(2i)" => "10"
        }
      }

      transformer = Frontyard::ApplicationForm::DateTimeParamTransformer.new(
        keys: [:event, :start_time],
        hash: params
      )
      transformer.call
      
      # The datetime parameters should be removed from the hash
      refute_includes params[:event], "start_time(1i)"
      refute_includes params[:event], "start_time(2i)"
      assert_includes params[:event], "title"
    end

    it "accepts custom time converter" do
      params = {
        event: {
          "start_time(1i)" => "2023",
          "start_time(2i)" => "10",
          "start_time(3i)" => "15"
        }
      }

      custom_converter = ->(year, month, day, hour, minute) { 
        Time.new(year, month, day, hour, minute, 0, "UTC") 
      }

      transformer = Frontyard::ApplicationForm::DateTimeParamTransformer.new(
        keys: [:event, :start_time],
        hash: params
      )
      result = transformer.call(time_converter: custom_converter)
      
      assert_kind_of Time, result
      assert_equal "UTC", result.zone
    end
  end

  describe ".process_params" do
    it "returns params unchanged by default" do
      params = { name: "test", value: 123 }
      result = Frontyard::ApplicationForm.process_params(params)
      assert_equal params, result
    end
  end

  describe ".format_date_parts" do
    it "is a private class method" do
      assert_raises(NoMethodError) do
        Frontyard::ApplicationForm.format_date_parts(:test, params: {})
      end
    end
  end
end 
