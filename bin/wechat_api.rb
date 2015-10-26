require 'typhoeus'

params = {grant_type: 'client_credential',
appid: 'wxd284e53ecd0e2b51',
secret: 'a1fd7beec066019b1b9b28efcba1e610'}
response = Typhoeus.get("https://api.weixin.qq.com/cgi-bin/token", params: params)
access_token = JSON.parse(response.body)['access_token']

body = {touser: "oY5IiuBFShGC8uMYyAkFlM8iMSnQ",
        msgtype: "text",
        text: {content: "Hello world"}}

response = Typhoeus.post("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{access_token}", body: body.to_json)
p response.body