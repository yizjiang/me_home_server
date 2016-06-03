# encoding: utf-8

class SubscribeWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2

  sidekiq_retry_in do |count|
    1 * (count + 1)
  end

  def perform(wid)
    wuser = WechatUser.find(wid)
    article = [{title: '点击头像设置智能搜索条件',
                body: '',
                pic_url: wuser.head_img_url,
                url: "#{CLIENT_HOST}/quick_search/?wid=#{wuser.id}"}]

    WechatRequest.new.send_articles(to_user: wuser.open_id, body: article)
  end
end