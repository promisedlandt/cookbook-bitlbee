action :install do
  updated_by_last_action = %w(bitlbee-plugin-otr).inject(false) do |anything_updated, pkg|
    package_resource = package pkg
    anything_updated || package_resource.updated_by_last_action?
  end

  new_resource.updated_by_last_action(updated_by_last_action)
end
