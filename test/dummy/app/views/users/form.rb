# frozen_string_literal: true

module Views
  module Users
    class Form < ApplicationForm
      def initialize(attributes = {})
        @attributes = attributes
      end

      def process_params(params)
        params.permit(:test).to_h
      end
    end
  end
end
