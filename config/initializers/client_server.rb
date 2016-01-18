client_config = YAML.load(ERB.new(File.read('./config/client_server.yml')).result)[Rails.env]

CLIENT_HOST = client_config['client_url']
SERVER_HOST = client_config['server_url']
CDN_HOST = client_config['cdn_url']