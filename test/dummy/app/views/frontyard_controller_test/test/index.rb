# frozen_string_literal: true

module Views
  module FrontyardControllerTest
    module Test
      class Index < ApplicationView
        def initialize(test_collection:, flash:, custom_field: nil)
          @test_collection = test_collection
          @flash = flash
          @custom_field = custom_field
        end

        def view_template
          div do
            text "Index view with #{@test_collection.length} items"
            if @custom_field
              div { "Custom field: #{@custom_field}" }
            end
            if @flash[:notice]
              div { "Flash notice: #{@flash[:notice]}" }
            end
          end
        end
      end
    end
  end
end
