include_recipe "runit"

runit_service "bitlbee" do
  owner node[:bitlbee][:user]
  group node[:bitlbee][:group]
  default_logger true
  action [:enable, :start]
end
