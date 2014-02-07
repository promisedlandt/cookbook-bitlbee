actions :create_or_modify, :delete

default_action :create_or_modify

attribute :username, kind_of: String, name_attribute: true
attribute :password, kind_of: String
