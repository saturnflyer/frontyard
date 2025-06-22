# frozen_string_literal: true

module Views
  module FrontyardControllerTest
    module Test
      class Show < ApplicationView
        def initialize(test_resource:, flash:)
          @test_resource = test_resource
          @flash = flash
        end

        def view_template
          div do
            text "Show view for #{@test_resource.name}"
            if @flash[:notice]
              div { "Flash notice: #{@flash[:notice]}" }
            end
          end
        end
      end
    end
  end
end 
