client_config = YAML.load(ERB.new(File.read('./config/client_server.yml')).result)[Rails.env]

CLIENT_HOST = client_config['client_url']
SERVER_HOST = client_config['server_url']
CDN_HOST = client_config['cdn_url']
TRACKING_SOURCE = {
                    "home_search_items" => "we_a",
                    "agent_request_items" => "agt_req",
                    "send_home_card" => "h_c",
                    "agent_send" => "agt_snd",
                    "home_map" => "h_m",
                    "home_game" => "h_g"
                  }
TRACKING_SOURCE.default = "other"
