# encoding: utf-8

class Question < ActiveRecord::Base
  belongs_to :user
  has_many :answers, foreign_key: 'qid'
  has_one :medias, foreign_key: 'reference_id', dependent: :destroy
  attr_accessible *column_names

  scope :unanswered, lambda{ |uid, latest|
    includes(:answers).where('accepted_aid is NULL AND created_at > ?', latest)
    .select{|q| q.answers.index{|a| a.uid == uid} == nil}
    }    #TODO more efficient query

  def as_json(options=nil)
    options ||= {}
    result = super(options)

    if media = self.media
      result.merge!({
                      is_audio: true,
                      media_url: media.media_url
                    })
    end
    result
  end

  def self.create_with_media(opts)
    transaction do
      q = create(open_id: opts[:open_id], text: opts[:text])
      media = Media.create(reference_id: q.id, media_id: opts[:media_id])
    end
  end
  def create_answer(text, replyee_id)
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

    agent = User.find(replyee_id)
    body = {touser: self.open_id,
            msgtype: 'text',
            text: {content: "#{agent.agent_extention.try(:cn_name) || agent.agent_extention.try(:agent_identifier)}(编号:#{agent.id}): #{text}"}}

    Typhoeus.post("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{access_token}", body: body.to_json)
    REDIS.setex("#{self.open_id}:wait_input", 600, 'like_agent')
  end
end