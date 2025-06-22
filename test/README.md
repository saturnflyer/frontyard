# Frontyard Test Suite

This directory contains comprehensive tests for the Frontyard Rails engine, specifically testing the controller functionality that allows Rails controllers to use Frontyard features.

## Test Structure

### Controller Tests

- `controllers/frontyard/controller_test.rb` - Main controller functionality tests
- `controllers/frontyard/controller_edge_cases_test.rb` - Edge cases and error handling tests

### Integration Tests

- `integration/frontyard_controller_integration_test.rb` - Full integration tests with Rails routing

### Test Dummy App

The `dummy/` directory contains a minimal Rails application used for testing:

- `app/controllers/application_controller.rb` - Base controller for tests
- `app/views/application_view.rb` - Base view class for tests
- `app/views/application_form.rb` - Base form class for tests
- `app/views/test/` - Test view classes for the TestController
- `app/views/edge_case/` - Test view classes for edge case testing

## Running Tests

To run all tests:

```bash
bundle exec rake test
```

To run specific test files:

```bash
bundle exec ruby -I test test/controllers/frontyard/controller_test.rb
bundle exec ruby -I test test/controllers/frontyard/controller_edge_cases_test.rb
bundle exec ruby -I test test/integration/frontyard_controller_integration_test.rb
```

## Test Coverage

The tests cover the following Frontyard controller functionality:

### `form` method
- Returns the correct form class based on controller name
- Handles different controller naming conventions

### `form_params` method
- Processes parameters through the form class
- Handles empty and complex parameter structures

### `render_view` method
- Renders the correct view class based on action name
- Passes controller data to views automatically
- Handles required and optional view parameters
- Includes flash messages in view data
- Supports additional render options (status, content_type, etc.)
- Handles edge cases like nil values and different key types

### Error Handling
- Proper error handling for missing view classes
- Error handling for missing required parameters
- Graceful handling of nil values

## Adding New Tests

When adding new tests:

1. Create test view classes in `dummy/app/views/` if needed
2. Follow the existing test patterns using mocha for mocking
3. Test both happy path and edge cases
4. Include integration tests for full Rails functionality

## Dependencies

- `mocha` - For mocking and stubbing in tests
- `minitest` - Rails default testing framework
- `simplecov` - For test coverage (when CI environment variable is set) 
