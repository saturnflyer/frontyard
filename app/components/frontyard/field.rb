module Frontyard
  class Field < Frontyard::ApplicationComponent
    include Phlex::Rails::Helpers::FormWith
    include Phlex::Rails::Helpers::Label
    include Phlex::Rails::Helpers::Pluralize
    include Phlex::Rails::Helpers::TextField
    include Phlex::Rails::Helpers::NumberField
    include Phlex::Rails::Helpers::CheckBox
    include Phlex::Rails::Helpers::DateSelect
    include Phlex::Rails::Helpers::OptionsForSelect
    include Phlex::Rails::Helpers::Select

    initialize_with :object, :attribute

    def view_template(&block)
      div(**self.class.config) do
        # Use basic HTML label to avoid Rails helper conflicts
        tag(:label) { attribute.to_s.humanize }

        case field_type
        when :text
          input(type: "text", name: object_attribute, **field_options)
        when :number
          input(type: "number", name: object_attribute, **field_options)
        when :date
          input(type: "date", name: object_attribute, **field_options)
        when :checkbox
          input(type: "checkbox", name: object_attribute, **field_options)
        else
          input(type: "text", name: object_attribute, **field_options)
        end
        yield if block_given?
      end
    end

    private

    def object_attribute
      if object&.class&.respond_to?(:name)
        "#{object.class.name.underscore}[#{attribute}]"
      else
        # Fallback for when object is nil or doesn't have a class name
        attribute.to_s
      end
    end

    def field_type
      # Determine field type based on attribute or object type
      case attribute.to_s
      when /_at$/, /_on$/
        :date
      when /_count$/, /_id$/
        :number
      when /_enabled$/, /_active$/
        :checkbox
      else
        :text
      end
    end

    def field_options
      # Return any additional options for the field
      {}
    end
  end
end
