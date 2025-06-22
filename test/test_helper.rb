# frozen_string_literal: true

if ENV["CI"]
  require "simplecov"
  SimpleCov.start "rails" do
    enable_coverage :branch
    add_filter "/test/"
    add_filter "/config/"
    add_filter "/bin/"
    add_filter "/lib/frontyard/version.rb"
  end
end
# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "dummy/config/environment"
require "rails/test_help"
require "minitest/autorun"
require "minitest/spec"

# Filter out Minitest backtrace while allowing Rails backtrace through
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
  ActiveSupport::TestCase.fixtures :all
end

class Minitest::Spec
  include ActiveSupport::Testing::Assertions
  # Add any shared helpers or setup here
end

# Ensure routes are loaded for integration tests
class ActionDispatch::IntegrationTest
  def setup
    super
    # Force reload routes in test environment
    Rails.application.routes.clear!
    load Rails.root.join("config", "routes.rb")
  end
end
