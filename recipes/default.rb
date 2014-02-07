include_recipe "bitlbee::_cookbook_configuration"

include_recipe "bitlbee::_platform_setup"

# Create system user and group
group node[:bitlbee][:group]

user node[:bitlbee][:user] do
  group node[:bitlbee][:group]
  system true
  shell "/bin/bash"
end

[node[:bitlbee][:config_dir],
 node[:bitlbee][:data_dir]].each do |dir|
  directory dir do
    mode 0755
    owner node[:bitlbee][:user]
    group node[:bitlbee][:group]
    recursive true
  end
end

# install stunnel for safe(r) ICQ connections
include_recipe "bitlbee::stunnel" unless node[:bitlbee][:skip_stunnel_installation]

# Install the application
if ["package"].include?(node[:bitlbee][:install_method])
  include_recipe "bitlbee::_install_#{ node[:bitlbee][:install_method] }"
else
  Chef::Log.error("bitlbee: installation method not recognized or set: #{ node[:bitlbee][:install_method] }")
end

# Which init style do we want to use?
if ["runit"].include?(node[:bitlbee][:init_style])
  include_recipe "bitlbee::_init_#{ node[:bitlbee][:init_style] }"
else
  Chef::Log.warn("bitlbee: init style not recognized or set: #{ node[:bitlbee][:init_style] }")
end

include_recipe "bitlbee::_gem_bitlbee_config"

node[:bitlbee][:users].each do |user|
  bitlbee_user_account user[:name] do
    password user[:password]
  end

  user[:accounts][:icq].each do |account|
    bitlbee_icq_account account[:handle] do
      user user[:name]
      password account[:password]
      user_cleartext_password user[:password]
    end
  end if user[:accounts][:icq]

  user[:accounts][:jabber].each do |account|
    bitlbee_jabber_account account[:handle] do
      user user[:name]
      password account[:password]
      user_cleartext_password user[:password]
    end
  end if user[:accounts][:jabber]

  user[:accounts][:facebook].each do |account|
    bitlbee_facebook_account account[:handle] do
      user user[:name]
      password account[:password] if account[:password]
      auth_strategy account[:auth_strategy] if account[:auth_strategy]
      user_cleartext_password user[:password]
    end
  end if user[:accounts][:facebook]

  user[:accounts][:gtalk].each do |account|
    bitlbee_gtalk_account account[:handle] do
      user user[:name]
      user_cleartext_password user[:password]
    end
  end if user[:accounts][:gtalk]

  user[:accounts][:hipchat].each do |account|
    bitlbee_hipchat_account account[:handle] do
      user user[:name]
      password account[:password]
      user_cleartext_password user[:password]
    end
  end if user[:accounts][:hipchat]

  if user[:accounts][:steam] && !user[:accounts][:steam].empty?
    bitlbee_steam_plugin "bitlbee_steam_plugin"

    user[:accounts][:steam].each do |account|
      bitlbee_steam_account account[:handle] do
        user user[:name]
        password account[:password]
        user_cleartext_password user[:password]
      end
    end
  end
end
