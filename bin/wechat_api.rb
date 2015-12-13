# encoding: utf-8
require 'typhoeus'
require 'open-uri'

#wx18034235da4be445
#64007b6d52d74fb2858ea90e28f8cd1b

#wxd284e53ecd0e2b51
#a1fd7beec066019b1b9b28efcba1e610

#wx8f6251caa9d36d5b
#b270c00cbd25f31830224f5c54f2363e

CLIENTID = 'wx18034235da4be445'
CLIENTSECRET = '64007b6d52d74fb2858ea90e28f8cd1b'
params = {grant_type: 'client_credential',
          appid: CLIENTID,
          secret: CLIENTSECRET}
response = Typhoeus.get("https://api.weixin.qq.com/cgi-bin/token", params: params)
access_token = JSON.parse(response.body)['access_token']


def upload_image(access_token)
  url = "https://api.weixin.qq.com/cgi-bin/media/upload?access_token=#{access_token}&type=image"
  response = Typhoeus.post(url, headers: { 'Content-Type' => 'multipart/form-data' }, body: {media: File.open("/Users/yizjiang/Projects/me_home_server/sample/leojyz_qr.jpeg","r")})
  p JSON.parse(response.body)
end

def user_info(access_token)
  open_id = "oNo8PuAJh6vYaXq6xycacOc2REkM"
  url = "https://api.weixin.qq.com/cgi-bin/user/info?access_token=#{access_token}&openid=#{open_id}&lang=zh_CN"
  response = Typhoeus.get(url)
  p response.body
end

def generate_qr_code(access_token)
  url = "https://api.weixin.qq.com/cgi-bin/qrcode/create?access_token=#{access_token}"
  body = {
    expire_seconds: 604800,
    action_name: "QR_SCENE",
    action_info:
      {
        scene:
          {
            scene_id: '3'
          }
      }
  }
  response = Typhoeus.post(url, body: body.to_json)
  p response.body
  ticket = URI::encode (JSON.parse(response.body)['ticket'])
  p ticket
  url = "https://mp.weixin.qq.com/cgi-bin/showqrcode?ticket=#{ticket}"
  response = Typhoeus.get(url)
  File.open('service_account.png', 'wb') do |outfile|
    outfile.write(response.body)
  end
end

def get_qr_code(ticket)
  url = "https://mp.weixin.qq.com/cgi-bin/showqrcode?ticket=#{ticket}"
  response = Typhoeus.get(url)
  p response
end


def reply(access_token)
  url = "https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{access_token}"
  body = {
    touser:"oNo8PuNxHTTGxRBWVKMs5mH7gp9M",
    msgtype:"text",
    text:
    {
      content:"Hello World"
    }
  }
  response = Typhoeus.post(url, body: body.to_json)
  p response.body
end


def publish_menu(access_token)
  url = "https://api.weixin.qq.com/cgi-bin/menu/create?access_token=#{access_token}"
  body = {
    button: [
      {
        name: "尊贵的买家",
        sub_button: [
          {
            type: "click",
            name: "智能找房",
            key: "s"
          },

          {
            type: "click",
            name: "红心房源",
            key: "fav"
          },

          {
            type: "click",
            name: "答疑解惑",
            key: "q"
          }

          #{
          #  type: "click",
          #  name: "房产经纪人",
          #  key: "a"
          #},
          #
          #{
          #  type: "click",
          #  name: "贷款经纪人",
          #  key: "l"
          #}
        ]
      },
      {
        name: "专业经纪人",
        sub_button: [
          {
            type: "click",
            name: "我的客户",
            key: "my_client"
          },
          {
            type: "click",
            name: "普通咨询",
            key: "cq"
          },
          {
            type: "click",
            name: "潜在买家",
            key: "pc"
          }]
      },

      {
        name: '合作伙伴',
        type: "click",
        key: 'agent_assist'
      }

    ]
  }
  response = Typhoeus.post(url, body: body.to_json)
  p response.body
end

p access_token
#user_info(access_token)
#upload_image(access_token)
#get_qr_code("gQEP8ToAAAAAAAAAASxodHRwOi8vd2VpeGluLnFxLmNvbS9xL09rTkIyUXJtX0lpQlJ6Wk01VzN5AAIEuMQ/VgMEgDoJAA==")
#generate_qr_code(access_token)
#reply(access_token)
publish_menu(access_token)