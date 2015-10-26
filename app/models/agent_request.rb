# encoding: utf-8

class AgentRequest < ActiveRecord::Base
  attr_accessible *column_names

  def sent_to_wechat
    params = {grant_type: 'client_credential',
              appid: 'wxd284e53ecd0e2b51',
              secret: 'a1fd7beec066019b1b9b28efcba1e610'}
    response = Typhoeus.get("https://api.weixin.qq.com/cgi-bin/token", params: params)
    access_token = JSON.parse(response.body)['access_token']

    body = {touser: self.open_id,
            msgtype: 'news',
            news: {articles: [
              {
                title: "Hello from #{self.agent_identifier_list}",
                description: "专业房产经纪人",
                url: "www.weibo.com/ilovefrada",
                picurl: "https://media.licdn.com/mpr/mpr/shrinknp_400_400/p/8/000/1b5/138/189337a.jpg"
              }]
            }
    }

    Typhoeus.post("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{access_token}", body: body.to_json)
  end
end