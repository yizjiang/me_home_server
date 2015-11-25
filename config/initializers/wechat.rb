wechat_config = YAML.load(ERB.new(File.read('./config/wechat_platform.yml')).result)[Rails.env]

WECHAT_CLIENTID = wechat_config['client_id']
WECHAT_CLIENTSECRET =wechat_config['client_secret']