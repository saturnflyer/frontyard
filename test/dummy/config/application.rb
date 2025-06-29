require_relative "boot"

# Load ActiveSupport first to ensure core extensions are available
require "active_support/all"

# Then load the rest of Rails
require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "active_model/railtie"
require "active_record/railtie"
require "action_mailer/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile
Bundler.require(*Rails.groups)
require "frontyard"

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only use the memory store
    config.cache_store = :memory_store

    # Enable logging to STDOUT in test mode
    if Rails.env.test?
      config.logger = Logger.new($stdout)
      config.log_level = :error
    end
  end
end
