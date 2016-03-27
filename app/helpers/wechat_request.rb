class WechatRequest
  attr_accessor :access_token

  def initialize(agent_account = false)
    @access_token = get_access_token(agent_account)
  end

  def get_access_token(agent_account)
    if agent_account
      client_id = AGENT_WECHAT_CLIENTID
      client_secret = AGENT_WECHAT_CLIENTSECRET
    else
      client_id = WECHAT_CLIENTID
      client_secret = WECHAT_CLIENTSECRET
    end
    params = {grant_type: 'client_credential',
              appid: client_id,
              secret: client_secret}
    response = Typhoeus.get("https://api.weixin.qq.com/cgi-bin/token", params: params)
    JSON.parse(response.body)['access_token']
  end

  def upload_image(file)
    url = "https://api.weixin.qq.com/cgi-bin/media/upload?access_token=#{@access_token}&type=image"
    response = Typhoeus.post(url, headers: {'Content-Type' => 'multipart/form-data'}, body: {media: File.open(file, "r")})
    JSON.parse(response.body)
  end

  def generate_qr_code(scene_id)
    url = "https://api.weixin.qq.com/cgi-bin/qrcode/create?access_token=#{@access_token}"
    body = {
      action_name: "QR_LIMIT_SCENE",
      action_info:
        {
          scene:
            {
              scene_id: scene_id
            }
        }
    }
    response = Typhoeus.post(url, body: body.to_json)
    ticket = URI::encode (JSON.parse(response.body)['ticket'])
    url = "https://mp.weixin.qq.com/cgi-bin/showqrcode?ticket=#{ticket}"
    response = Typhoeus.get(url)
    file = "#{Rails.root}/public/agents/#{scene_id}.png"
    File.open(file, 'wb') do |outfile|
      outfile.write(response.body)
    end
    return "/public/agents/#{scene_id}.png"
  end

  def send_text(opts)
    body = {touser: opts[:to_user],
            msgtype: 'text',
            text: {
              content: opts[:body]
            }
    }
    Typhoeus.post("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{@access_token}", body: body.to_json)
  end

  def send_articles (opts)
    body = {touser: opts[:to_user],
            msgtype: 'news',
            news: {
              articles: opts[:body]
            }
    }

    Typhoeus.post("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{@access_token}", body: body.to_json)
  end

  def send_audio(opts)
    body = {touser: opts[:to_user],
            msgtype: 'voice',
            voice: {
              media_id: opts[:mid]
            }
    }

    Typhoeus.post("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{@access_token}", body: body.to_json)
  end

  def fetch_user_info(open_id)
    url = "https://api.weixin.qq.com/cgi-bin/user/info?access_token=#{@access_token}&openid=#{open_id}&lang=zh_CN"
    response = Typhoeus.get(url)
    JSON.parse(response.body)
  end

  def download_media(media_id)
    url = "https://api.weixin.qq.com/cgi-bin/media/get?access_token=#{@access_token}&media_id=#{media_id}"
    response = Typhoeus.get(url)

    filedata = response.body

    content_disposition = response.headers["content-disposition"]
    filename = content_disposition.match(/filename=(\"?)(.+)\1/)[2] rescue nil

    local_file = "./public/wechat_media/#{filename}"

    File.open(local_file, "w+") { |file| file.write filedata.force_encoding('utf-8') }

    return "#{SERVER_HOST}/wechat_media/#{filename}"
  end
end