# frozen_string_literal: true

module Views
  module EdgeCase
    class ComplexAction < ApplicationView
      def initialize(test_collection:, flash:, custom_data: nil)
        @test_collection = test_collection
        @flash = flash
        @custom_data = custom_data
      end

      def view_template
        div do
          plain "Complex action view with #{@custom_data}"
        end
      end
    end
  end
end
