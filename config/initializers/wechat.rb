wechat_config = YAML.load(ERB.new(File.read('./config/wechat_platform.yml')).result)[Rails.env]


AGENT_WECHAT_CLIENTID = wechat_config['agent_client_id']
AGENT_WECHAT_CLIENTSECRET =wechat_config['agent_client_secret']
AGENT_ACCOUNT_ID = wechat_config['agent_account_id']

WECHAT_CLIENTID = wechat_config['client_id']
WECHAT_CLIENTSECRET = wechat_config['client_secret']
ACCOUNT_ID = wechat_config['account_id']