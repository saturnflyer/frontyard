# frozen_string_literal: true

module Views
  module EdgeCase
    class Index < ApplicationView
      def initialize(test_collection:, flash:, nil_value: nil, symbol_key: nil, string_key: nil, 
                     string_data: nil, number_data: nil, array_data: nil, hash_data: nil,
                     true_value: nil, false_value: nil)
        @test_collection = test_collection
        @flash = flash
        @nil_value = nil_value
        @symbol_key = symbol_key
        @string_key = string_key
        @string_data = string_data
        @number_data = number_data
        @array_data = array_data
        @hash_data = hash_data
        @true_value = true_value
        @false_value = false_value
      end

      def view_template
        div do
          plain "Edge case index view"
          if @symbol_key
            div { plain "Symbol key: #{@symbol_key}" }
          end
          if @string_key
            div { plain "String key: #{@string_key}" }
          end
          if @string_data
            div { plain "String data: #{@string_data}" }
          end
          if @number_data
            div { plain "Number data: #{@number_data}" }
          end
          if @array_data
            div { plain "Array data: #{@array_data.join(', ')}" }
          end
          if @hash_data
            div { plain "Hash data: #{@hash_data[:key]}" }
          end
          if @true_value
            div { plain "True value: #{@true_value}" }
          end
          if @false_value == false
            div { plain "False value: #{@false_value}" }
          end
        end
      end
    end
  end
end 
