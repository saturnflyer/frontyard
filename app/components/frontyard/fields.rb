module Frontyard
  class Fields < Frontyard::ApplicationComponent
    DefaultConfig = Config.init(
      class: "frontyard-fields",
    )

    def field(*args, **kwargs, &block)
      name = args.first
      options = kwargs
      div(class: "frontyard-field") do
        label do
          plain(name.to_s.humanize)
          input(type: options[:type] || "text", name: name, **render_attributes(options))
        end
      end
    end

    private

    def render_attributes(options)
      attrs = options.except(:type)
      # Handle boolean attributes
      attrs.transform_values! do |value|
        if value.is_a?(TrueClass)
          value.to_s
        elsif value.is_a?(FalseClass)
          nil
        else
          value
        end
      end
      attrs.compact
    end
  end
end 
