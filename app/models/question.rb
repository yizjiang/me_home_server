# encoding: utf-8

class Question < ActiveRecord::Base
  belongs_to :user
  has_many :answers, foreign_key: 'qid'
  attr_accessible *column_names

  scope :unanswered, lambda{ |uid| includes(:answers).where(accepted_aid: nil).select{|q| q.answers.index{|a| a.uid == 5} == nil} }    #TODO more efficient query

  def create_answer(text, replyee_id)
    self.answers << Answer.find_or_create_by_uid_and_body(replyee_id, text)
    if self.open_id
      send_to_wechat(text, replyee_id) # TODO hook method
    end
  end

  def send_to_wechat(text, replyee_id)
    params = {grant_type: 'client_credential',
              appid: WECHAT_CLIENTID,
              secret: WECHAT_CLIENTSECRET}
    response = Typhoeus.get("https://api.weixin.qq.com/cgi-bin/token", params: params)
    access_token = JSON.parse(response.body)['access_token']


    body = {touser: self.open_id,
            msgtype: 'text',
            text: {content: "我们共为您收集了1条经纪人回复，如想了解更多详情，请回复经纪人的编码获取联系方式"}}

    Typhoeus.post("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{access_token}", body: body.to_json)

    body = {touser: self.open_id,
            msgtype: 'text',
            text: {content: "#{User.find(replyee_id).agent_extention.agent_identifier}: #{text} "}}

    Typhoeus.post("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{access_token}", body: body.to_json)

    REDIS.set("#{ self.open_id}:wait_input", :like_agent)
  end
end