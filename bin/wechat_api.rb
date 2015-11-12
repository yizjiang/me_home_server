# encoding: utf-8
require 'typhoeus'

CLIENTID = 'wx18034235da4be445'     #wxd284e53ecd0e2b51
CLIENTSECRET = '64007b6d52d74fb2858ea90e28f8cd1b'  #a1fd7beec066019b1b9b28efcba1e610
params = {grant_type: 'client_credential',
          appid: CLIENTID,
          secret: CLIENTSECRET}
response = Typhoeus.get("https://api.weixin.qq.com/cgi-bin/token", params: params)
access_token = JSON.parse(response.body)['access_token']


def upload_image(access_token)
  url = "https://api.weixin.qq.com/cgi-bin/media/upload?access_token=#{access_token}&type=image"
  response = Typhoeus.post(url, headers: { 'Content-Type' => "multipart/form-data" }, body: File.open("/Users/yizjiang/Projects/me_home_server/sample/leojyz_qr.jpeg","r"))
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
            scene_id: '5'
          }
      }
  }
  response = Typhoeus.post(url, body: body.to_json)
  p JSON.parse(response.body)

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
            name: "快速搜索",
            key: "s"
          },

          {
            type: "click",
            name: "提问",
            key: "q"
          },

          {
            type: "click",
            name: "联系经纪人",
            key: "a"
          },

          {
            type: "click",
            name: "更新快速搜索",
            key: "u"
          }]
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
        name: "合作伙伴",
        sub_button: [
          {
            type: "view",
            name: "我的页面",
            url: "http://usreclub.com:3001/#"
          }]
      }

    ]
  }
  response = Typhoeus.post(url, body: body.to_json)
  p response.body
end

p access_token
user_info(access_token)
#upload_image(access_token)
#get_qr_code("gQEP8ToAAAAAAAAAASxodHRwOi8vd2VpeGluLnFxLmNvbS9xL09rTkIyUXJtX0lpQlJ6Wk01VzN5AAIEuMQ/VgMEgDoJAA==")
#generate_qr_code(access_token)
#reply(access_token)
#publish_menu(access_token)