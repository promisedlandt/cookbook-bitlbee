action :install do
  %w(git bitlbee-dev libtool libgmp-dev pkg-config libglib2.0-dev).each do |pkg|
    package pkg
  end

  steam_plugin_path = ::File.join(Chef::Config[:file_cache_path], "bitlbee-steam-plugin")

  directory steam_plugin_path do
    action :create
  end

  git steam_plugin_path do
    repository "https://github.com/jgeboski/bitlbee-steam.git"
    reference "master"
    action :sync
  end

  execute "autogen-bitlbee-steam-plugin" do
    cwd steam_plugin_path
    command "./autogen.sh --prefix=/usr"
    creates ::File.join(steam_plugin_path, "Makefile")
  end

  execute "make-bitlbee-steam-plugin" do
    cwd steam_plugin_path
    command "make"
    creates ::File.join(steam_plugin_path, "steam", "steam.la")
  end

  make_install_bitlbee_steam_plugin_resource = execute "make-install-bitlbee-steam-plugin" do
    cwd steam_plugin_path
    command "make install"
    creates "/usr/lib/bitlbee/steam.la"
  end

  new_resource.updated_by_last_action(make_install_bitlbee_steam_plugin_resource.updated_by_last_action?)
end
