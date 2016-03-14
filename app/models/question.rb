# encoding: utf-8

class Question < ActiveRecord::Base
  belongs_to :user
  has_many :answers, foreign_key: 'qid'
  has_one :medias, foreign_key: 'reference_id', dependent: :destroy
  attr_accessible *column_names

  scope :unanswered, lambda{ |uid, latest| includes(:answers).where('accepted_aid is NULL AND created_at > ?', latest).select{|q| q.answers.index{|a| a.uid == uid} == nil} }    #TODO more efficient query

  def self.create_with_media(opts)
    transaction do
      q = create(open_id: opts[:open_id], text: opts[:text])
      Media.create(reference_id: q.id, media_id: opts[:media_id])
    end
  end
  def create_answer(text, replyee_id)
    #self.accepted_aid = replyee_id
    self.answers << Answer.find_or_create_by_uid_and_body(replyee_id, text)
    self.save
    if self.open_id
      send_to_wechat(text, replyee_id) # TODO hook method
    end
  end

  def media
    Media.find_by_reference_id(self.id)
  end

  def send_to_wechat(text, replyee_id)
    params = {grant_type: 'client_credential',
              appid: WECHAT_CLIENTID,
              secret: WECHAT_CLIENTSECRET}
    response = Typhoeus.get("https://api.weixin.qq.com/cgi-bin/token", params: params)
    access_token = JSON.parse(response.body)['access_token']


    body = {touser: self.open_id,
            msgtype: 'text',
            text: {content: "#{User.find(replyee_id).agent_extention.agent_identifier}: #{text} \n 如果满意请回复经纪人姓名获取联系方式"}}

    Typhoeus.post("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{access_token}", body: body.to_json)

    REDIS.set("#{ self.open_id}:wait_input", :like_agent)
  end
end