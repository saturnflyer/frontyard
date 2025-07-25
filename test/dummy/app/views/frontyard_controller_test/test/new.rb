# frozen_string_literal: true

module Views
  module FrontyardControllerTest
    module Test
      class New < ApplicationView
        def initialize(test_collection:, flash:)
          @test_collection = test_collection
          @flash = flash
        end

        def view_template
          div { "Index view with #{@test_collection.length} items" }
        end
      end
    end
  end
end
