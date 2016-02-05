# encoding: utf-8
require 'typhoeus'
require 'open-uri'
require 'json'
#wx18034235da4be445     wx8f2bdf36a0d0448a
#64007b6d52d74fb2858ea90e28f8cd1b     d4624c36b6795d1d99dcf0547af5443d

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
  File.open('agent_login.png', 'wb') do |outfile|
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
        name: '找房',
        type: 'click',
        key: 's'
      },

      {
        name: '找经纪人',
        type: 'click',
        key: 'a'
      },

      {
        name: "我的觅家",
        sub_button: [
          {
            type: "click",
            name: "红心房源",
            key: "fav"
          },

          {
            type: "click",
            name: "提问",
            key: "q"
          },

          {
            type: "click",
            name: "更新智能搜索",
            key: "u"
          },

          {
            type: "click",
            name: "房产经纪人",
            key: "a"
          },

          {
            type: "click",
            name: "贷款经纪人",
            key: "l"
          }

        ]}
      ]

      #
      #{
      #  name: '客户统计',
      #  type: 'click',
      #  key: 'my_client'
      #},
      #
      #{
      #  name: '普通咨询',
      #  type: 'click',
      #  key: 'cq'
      #},
      #
      #{
      #  name: '我',
      #  sub_button: [
      #        {
      #          type: "click",
      #          name: "觅家二维码",
      #          key: "meejia_qr_code"
      #        },
      #
      #        {
      #          type: "click",
      #          name: "主页设置",
      #          key: "agent_page"
      #        },
      #
      #        {
      #          type: "click",
      #          name: "更改联系方式",
      #          key: "update_qr"
      #        }
      #  ]
      #
      #}]
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
