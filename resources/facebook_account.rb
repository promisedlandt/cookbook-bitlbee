actions :create_or_modify, :remove

default_action :create_or_modify

attribute :handle, kind_of: String, name_attribute: true
attribute :user, kind_of: String, required: true
attribute :auth_strategy, equal_to: [:oauth, :password, "oauth", "password"], default: :oauth
attribute :user_cleartext_password, kind_of: String
attribute :password, kind_of: String
