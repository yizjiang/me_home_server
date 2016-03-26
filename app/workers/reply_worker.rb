# encoding: utf-8

class ReplyWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(wid, event)
    WechatRequest.new.send_text(to_user: wid, body: '您可以回复经纪人编号获取联系方式，我们的经纪人也会尽快与您取得联系')
  end
end