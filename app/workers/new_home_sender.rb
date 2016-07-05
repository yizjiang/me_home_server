# encoding: utf-8

class NewHomeSender
  include Sidekiq::Worker
  sidekiq_options retry: 3

  sidekiq_retry_in do |count|
    1 * (count + 1)
  end

  sidekiq_retries_exhausted do
    self.class.seed
  end

  def perform(last_time)
    homes = Home.where('created_at > ? AND created_at < ?', last_time, Time.now).includes(:home_cn)
    homes = Hash[homes.group_by {|i| i.city}.sort_by {|_, value| value.size}]
    articles = []
    homes.each do |k, v|
      pic_url = File.join(CDN_HOST, v.first.images.first.image_url)
      articles << {title: "#{k}有#{v.size}处新房更新,请点击查看",
                  body: "",
                  picurl: pic_url,
                  url: File.join(CLIENT_HOST, "homeMap?ids=#{v.map(&:id).join(',')}")}

    end
    WechatUser.all.each do |wuser|
      WechatRequest.new.send_articles(to_user: wuser.open_id, body: articles.reverse[0..9])
    end
    self.class.seed
  end

  def self.seed
    NewHomeSender.perform_in(7.days, Time.now)
  end
end
