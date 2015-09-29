RACK_ENV ||= 'development'

client_config = YAML.load(ERB.new(File.read('./config/client_server.yml')).result)[RACK_ENV]

CLIENT_HOST = client_config['client_server_url']