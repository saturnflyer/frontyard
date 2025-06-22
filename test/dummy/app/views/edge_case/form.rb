# frozen_string_literal: true

module Views
  module EdgeCase
    class Form < ApplicationForm
      def initialize(attributes = {})
        @attributes = attributes
      end

      def process_params(params)
        params.to_h
      end
    end
  end
end 
