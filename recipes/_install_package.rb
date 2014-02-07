include_recipe "apt" if platform_family?("debian")

template "/etc/default/bitlbee" do
  source "default.erb"
  backup false
  mode 00600
  owner node[:bitlbee][:user]
  group node[:bitlbee][:group]
end

arch = node[:kernel][:machine] == "x86_64" ? "amd64" : "i386"

if %w(lucid oneiric precise quantal raring squeeze testing wheezy).include?(node[:lsb][:codename])
  dist = node[:lsb][:codename]
elsif node[:lsb][:codename] == "sid"
  dist = "testing"
else
  Chef::Log.error "Can't determine dist codename, or not supported codename: #{ node[:lsb][:codename] }, platform_version: #{ node[:platform_version] }"
end

apt_repository "bitlbee" do
  uri "http://code.bitlbee.org/debian/devel/#{ dist }/#{ arch }"
  key "bitlbee_apt_key"
  cookbook "bitlbee"
  distribution "./"
  action :add
  notifies :run, "execute[apt-get update]", :immediately
end

package "bitlbee" do
  action :install
  options "-o Dpkg::Options::=\"--force-confold\" --force-yes"
end
