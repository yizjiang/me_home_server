# encoding: utf-8

class ReplyWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(wid, event, reference_id = nil)
    if wid
      body = ''
      case event
        when 'need_agent'
          body = '您可以回复经纪人编号获取联系方式，我们的经纪人也会尽快与您取得联系'
        when 'submit_answer'
          body = '您可以回复经纪人编号获取联系方式.'
        when 'request_response'
          request = AgentRequest.find(reference_id)
          agent = User.find(request.to_user)
          name = agent.agent_extention.cn_name || agent.wechat_user.nickname
          body = "#{name}: #{request.body}"

          article = [{title: "#{name}希望为您服务",
                      body: '',
                      pic_url: agent.qr_code,
                      url: agent.qr_code}]

          WechatRequest.new.send_articles(to_user: wid, body: article)
      end
      WechatRequest.new.send_text(to_user: wid, body: body)
    end
  end
end