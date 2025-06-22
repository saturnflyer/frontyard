# frozen_string_literal: true

module Views
  module EdgeCase
    class ActionWithOptionalParam < ApplicationView
      def initialize(test_collection:, flash:, optional_param: nil)
        @test_collection = test_collection
        @flash = flash
        @optional_param = optional_param
      end

      def view_template
        div do
          plain "Action with optional params: #{@optional_param}"
        end
      end
    end
  end
end 
