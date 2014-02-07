action :create_or_modify do
  bb_config = BitlbeeConfig::Config.new(user: BitlbeeConfig::User.new(nick: new_resource.username,
                                                                      cleartext_password: new_resource.password))

  bb_config.save_to_directory(::File.join(node[:bitlbee][:data_dir]))
  new_resource.updated_by_last_action(true)
end

action :delete do
  BitlbeeConfig::Config.delete_from_directory_for_user(node[:bitlbee][:data_dir], new_resource.user)
  new_resource.updated_by_last_action(true)
end
