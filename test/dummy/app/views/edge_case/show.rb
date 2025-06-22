# frozen_string_literal: true

module Views
  module EdgeCase
    class Show < ApplicationView
      def initialize(test_resource:, flash:)
        @test_resource = test_resource
        @flash = flash
      end

      def view_template
        div do
          plain "Edge case show view"
        end
      end
    end
  end
end 
