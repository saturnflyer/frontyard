# frozen_string_literal: true

module Frontyard
  class ApplicationView < ::Frontyard::ApplicationComponent
    include Phlex::Rails::Helpers::ContentFor

    def page_links(&)
      render PageLinks.new(&)
    end

    def render_form(**)
      render namespace::Form.new(**)
    end

    def render_fragment(namespace: nil, **)
      namespace ||= self.namespace
      render "#{namespace}::Fragment".constantize.new(**)
    end

    def notice = flash[:notice]

    def alert = flash[:alert]

    def error = flash[:error]
  end
end
