# frozen_string_literal: true

module Frontyard
  class Actions < Frontyard::ApplicationComponent
    ButtonConfig = Config.init(
      buttons: {
        submit: {
          type: "submit",
          text: "Submit"
        },
        cancel: {
          type: "cancel",
          text: "Cancel"
        }
      }
    )

    def initialize(**kwargs, &block)
      filtered_kwargs = filter_kwargs_for(self.class.superclass, kwargs)
      super(&block)
      @button_config = ButtonConfig.merge(kwargs.except(*filtered_kwargs.keys))
    end

    def view_template(&block)
      div(**self.class.config) do
        if block_given?
          yield
        else
          @button_config[:buttons].each do |_key, data|
            button(type: data[:type]) { data[:text] }
          end
        end
      end
    end
  end
end
