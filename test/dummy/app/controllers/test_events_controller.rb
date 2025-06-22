class TestEventsController < ActionController::Base
  def create
    # Simulate the form processing that would happen in a real controller
    processed_params = form.process_params(params)
    
    # Return the processed params as JSON for testing
    render json: { processed_params: processed_params.to_s }
  end

  private

  def form
    TestEventForm
  end
end

class TestEventForm < Frontyard::ApplicationForm
  def self.process_params(params)
    # Simulate processing datetime parameters
    # This returns just the converted Time object
    format_date_parts(:event, :start_time, params: params)
  end

  def self.format_date_parts(*keys, params:)
    Frontyard::ApplicationForm::DateTimeParamTransformer.new(keys: keys, hash: params).call
  end
end 
