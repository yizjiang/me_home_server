# encoding: utf-8

class AgentRequest < ActiveRecord::Base
  attr_accessible *column_names
  after_create :sent_to_wechat

  def as_json
    result = super
    result['body'] = result['body'] % {detail: ""}
    result['link'] = "#{CLIENT_HOST}/home/#{self.request_context_id}"
    result
  end

  def sent_to_wechat
    to_user = User.find(self.to_user)
    open_id = to_user.try(:wechat_user).open_id
    if open_id
      params = {grant_type: 'client_credential',
                appid: AGENT_WECHAT_CLIENTID,
                secret: AGENT_WECHAT_CLIENTSECRET}
      response = Typhoeus.get("https://api.weixin.qq.com/cgi-bin/token", params: params)
      access_token = JSON.parse(response.body)['access_token']

      home = Home.find(self.request_context_id)
      body = {touser: open_id,
              msgtype: 'news',
              news: {articles: [
                {
                  title: "编号#{self.id}" + self.body % {detail: "位于#{home.city}的#{home.addr1}房源信息"},
                  description: '点击图片查看',
                  url: "#{CLIENT_HOST}/home/#{home.id}/?uid=#{self.to_user}",
                  picurl: home.images.first
                }]
              }
      }

      Typhoeus.post("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{access_token}", body: body.to_json)
    end

  end
end