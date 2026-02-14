require "phlex-rails"

module Frontyard
  class Engine < ::Rails::Engine
    isolate_namespace Frontyard

    initializer "frontyard.controller" do
      ActiveSupport.on_load(:action_controller_base) do
        include Frontyard::Controller
      end
    end

    initializer "frontyard.view" do
      ActiveSupport.on_load(:action_view) do
        Dir[Frontyard::Engine.root.join("app/views/frontyard/**/*.rb")].each { |file| require file }
      end
    end
  end
end
