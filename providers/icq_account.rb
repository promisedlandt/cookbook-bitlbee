action :create_or_modify do
  bb_config = BitlbeeConfig::Config.from_directory_for_user(node[:bitlbee][:data_dir], new_resource.user)
  bb_config.user.cleartext_password = new_resource.user_cleartext_password
  bb_config.user.add_or_replace_account(BitlbeeConfig::Accounts::Icq.new(handle: new_resource.handle,
                                                                         cleartext_password: new_resource.password
                                                                        ))

  bb_config.save_to_directory(::File.join(node[:bitlbee][:data_dir]))
  new_resource.updated_by_last_action(true)
end

action :remove do
  bb_config = BitlbeeConfig::Config.from_directory_for_user(node[:bitlbee][:data_dir], new_resource.user)
  account_to_delete = BitlbeeConfig::Accounts::Icq.new(handle: new_resource.handle)

  bb_config.user.remove_account(account_to_delete)
  new_resource.updated_by_last_action(true)
end
