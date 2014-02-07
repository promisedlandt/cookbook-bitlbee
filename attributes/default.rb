default[:bitlbee][:user] = "bitlbee"
default[:bitlbee][:group] = "bitlbee"

default[:bitlbee][:init_style] = "runit"
default[:bitlbee][:install_method] = "package"

default[:bitlbee][:config_dir] = "/etc/bitlbee"
default[:bitlbee][:data_dir] = "/var/lib/bitlbee"

default[:bitlbee][:port] = "6667"

default[:bitlbee][:skip_stunnel_installation] = true

default[:bitlbee][:bitlbee_config][:gem_version] = "1.0.0"

default[:bitlbee][:users] = []
