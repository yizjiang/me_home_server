# encoding: utf-8
require 'typhoeus'

params = {grant_type: 'client_credential',
          appid: 'wxd284e53ecd0e2b51',
          secret: 'a1fd7beec066019b1b9b28efcba1e610'}
response = Typhoeus.get("https://api.weixin.qq.com/cgi-bin/token", params: params)
access_token = JSON.parse(response.body)['access_token']


url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=wxd284e53ecd0e2b51&redirect_uri=http%3A%2F%2Fb2325724.ngrok.io%2Fwechat%2Fcallback&response_type=code&scope=snsapi_base&state=123#wechat_redirect"

body = {touser: "oY5IiuBFShGC8uMYyAkFlM8iMSnQ",
        msgtype: 'news',
        news: {articles: [
          {
            title: "Hello",
            description: "agent",
            url: url,
            picurl: "https://media.licdn.com/mpr/mpr/shrinknp_400_400/p/8/000/1b5/138/189337a.jpg"
          }]
        }
}

url = "https://api.weixin.qq.com/cgi-bin/menu/create?access_token=#{access_token}"
body = {
  button: [
    {
      type: "click",
      name: "咨询经纪人",
      key: "a"
    },
    {
      name: "我的觅家",
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
          name: "更新快速搜索",
          key: "u"
        }]
    }]
}
response = Typhoeus.post(url, body: body.to_json)
p response.body