node.set[:bitlbee][:service_to_be_notified] = case node[:bitlbee][:init_style].to_s
                                              when "none"
                                                nil
                                              when "runit"
                                                "runit_service[bitlbee]"
                                              else
                                                "service[bitlbee]"
                                              end
