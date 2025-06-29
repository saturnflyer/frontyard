# frozen_string_literal: true

module Frontyard
  class ApplicationForm < Frontyard::ApplicationComponent
    include Phlex::Rails::Helpers::DatetimeField
    include Phlex::Rails::Helpers::FormWith
    include Phlex::Rails::Helpers::Label
    include Phlex::Rails::Helpers::Pluralize
    include Phlex::Rails::Helpers::TextField

    def form_actions(**kwargs, &block)
      render Frontyard::Actions.new(**kwargs, &block)
    end

    def field(attribute, **kwargs, &block)
      # Use the form object if available, otherwise use a default object
      form_object = respond_to?(:object) ? object : self
      render Frontyard::Field.new(object: form_object, attribute: attribute, **kwargs, &block)
    end

    # Default object method - subclasses can override this
    def object
      nil
    end

    DateTimeParamTransformer = Data.define(:keys, :hash) do
      def call(time_converter: Time.zone.method(:local))
        leaf = keys.pop
        data = keys.reduce(hash) do |memo, key|
          memo[key] ||= {}
        end

        values = []
        # Check for both string and symbol keys
        datetime_keys = [
          "#{leaf}(1i)", :"#{leaf}(1i)",
          "#{leaf}(2i)", :"#{leaf}(2i)",
          "#{leaf}(3i)", :"#{leaf}(3i)",
          "#{leaf}(4i)", :"#{leaf}(4i)",
          "#{leaf}(5i)", :"#{leaf}(5i)"
        ]

        datetime_keys.each_slice(2) do |string_key, symbol_key|
          value = data.delete(string_key) || data.delete(symbol_key)
          values << value if value
        end

        # Filter out nil values and provide defaults
        filtered_values = values.compact
        if filtered_values.empty?
          # If no values provided, use current time
          Time.current
        else
          # Pad with defaults for missing parts
          year = filtered_values[0] || Time.current.year
          month = filtered_values[1] || 1
          day = filtered_values[2] || 1
          hour = filtered_values[3] || 0
          minute = filtered_values[4] || 0

          time_converter.call(year, month, day, hour, minute)
        end
      end
    end

    class << self
      def process_params(params)
        params
      end

      private

      def format_date_parts(*keys, params:)
        DateTimeParamTransformer.new(keys: keys, hash: params).call
      end
    end
  end
end
