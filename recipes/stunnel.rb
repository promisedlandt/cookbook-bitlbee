include_recipe "stunnel"

stunnel_connection "bitlbee_icq" do
  connect "slogin.icq.com:443"
  accept "127.0.0.1:5190"
  notifies :restart, "service[stunnel]"
end
