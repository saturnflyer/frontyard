# frozen_string_literal: true

module Frontyard
  class PageLinks < Frontyard::ApplicationComponent
    def page_link(text, url, **options)
      options = {
        class: "page-link"
      }.merge(options)
      link_to text, url, **options
    end

    def button(text, object, **options)
      options = {
        class: "page-button",
        form: {class: "inline-button-form"}
      }.merge(options)
      button_to text, object, **options
    end

    def dangerous_button(text, object, options)
      options = {
        class: "page-button dangerous"
      }.merge(options)
      button(text, object, **options)
    end
  end
end
