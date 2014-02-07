include_recipe "bitlbee::_platform_setup_#{ node[:platform_family] }" if %w(debian).include?(node[:platform_family])
