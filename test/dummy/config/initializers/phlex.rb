# Define the Views module for the dummy app
module Views; end

# Define the Components module for the dummy app (if needed)
module Components
  extend Phlex::Kit
  include Frontyard
end

Rails.autoloaders.main.push_dir("#{Rails.root}/app/views", namespace: Views)

# Only push components directory if it exists and contains files
components_dir = "#{Rails.root}/app/components"
if Dir.exist?(components_dir) && !Dir.empty?(components_dir)
  Rails.autoloaders.main.push_dir(components_dir, namespace: Components)
end
