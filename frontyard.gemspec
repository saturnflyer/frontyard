require_relative "lib/frontyard/version"

Gem::Specification.new do |spec|
  spec.name = "frontyard"
  spec.version = Frontyard::VERSION
  spec.authors = ["Jim Gay"]
  spec.email = ["jim@saturnflyer.com"]
  spec.homepage = "https://github.com/saturnflyer/frontyard"
  spec.summary = "Frontyard is a Rails engine for creating and managing views with Phlex."
  spec.description = "Use Frontyard in your rails app to simplify the use of Phlex views."
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/saturnflyer/frontyard"
  spec.metadata["changelog_uri"] = "https://github.com/saturnflyer/frontyard/blob/main/CHANGELOG.md"

  spec.required_ruby_version = ">= 3.4.0"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.0"
  spec.add_dependency "phlex-rails", ">= 2.0.2"
  spec.add_dependency "contours", ">= 0.1.1"
end
