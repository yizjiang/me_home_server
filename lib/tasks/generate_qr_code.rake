# encoding: utf-8
namespace :qrcode do
  task :client => :environment do
    params = {grant_type: 'client_credential',
              appid: WECHAT_CLIENTID,
              secret: WECHAT_CLIENTSECRET}
    response = Typhoeus.get("https://api.weixin.qq.com/cgi-bin/token", params: params)
    access_token = JSON.parse(response.body)['access_token']
    generate_qr_code(access_token, 'login')
  end

  task :agent  => :environment do
    params = {grant_type: 'client_credential',
              appid: AGENT_WECHAT_CLIENTID,
              secret: AGENT_WECHAT_CLIENTSECRET}
    response = Typhoeus.get("https://api.weixin.qq.com/cgi-bin/token", params: params)
    access_token = JSON.parse(response.body)['access_token']
    generate_qr_code(access_token, 'agent_login')
  end

  def generate_qr_code(access_token, filename)
    url = "https://api.weixin.qq.com/cgi-bin/qrcode/create?access_token=#{access_token}"
    body = {
      action_name: "QR_LIMIT_SCENE",
      action_info:
        {
          scene:
            {
              scene_id: '3'
            }
        }
    }
    response = Typhoeus.post(url, body: body.to_json)
    ticket = URI::encode (JSON.parse(response.body)['ticket'])
    url = "https://mp.weixin.qq.com/cgi-bin/showqrcode?ticket=#{ticket}"
    response = Typhoeus.get(url)
    File.open("#{filename}.png", 'wb') do |outfile|
      outfile.write(response.body)
    end
    FileUtils.mv("#{filename}.png", 'public/shared_qr/')
  end
end
