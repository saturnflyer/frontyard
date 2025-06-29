# frozen_string_literal: true

module Views
  module Test
    class Show < ApplicationView
      def initialize(test_resource:, flash:)
        @test_resource = test_resource
        @flash = flash
      end

      def view_template
        div do
          plain "Show view for #{@test_resource.name}"
          if @flash[:notice]
            div { plain "Flash notice: #{@flash[:notice]}" }
          end
        end
      end
    end
  end
end
