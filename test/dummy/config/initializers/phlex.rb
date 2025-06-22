# Define the Views module for the dummy app
module Views; end

# Define the Components module for the dummy app (if needed)
module Components
  extend Phlex::Kit
  include Frontyard
end

Rails.autoloaders.main.push_dir("#{Rails.root}/app/views", namespace: Views)
Rails.autoloaders.main.push_dir("#{Rails.root}/app/components", namespace: Components)
