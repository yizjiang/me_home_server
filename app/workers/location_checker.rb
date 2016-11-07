# encoding: utf-8

class LocationChecker
  include Sidekiq::Worker
  sidekiq_options retry: 2

  sidekiq_retry_in do |count|
    count
  end

  sidekiq_retries_exhausted do |msg|
    open_id = msg['args'][0]
    wuser = WechatUser.find_by_open_id(open_id)
    WechatRequest.new.send_text(to_user: open_id, body: '无法获取地址，请您 1.前往手机设置开启微信的位置服务. 2.允许公众号获取地址(您可以点击右上角菜单开启)')
    send_region_article(wuser)
  end

  def perform(uid)
    @uid = uid
    location = REDIS.get("#{uid}:location")
    unless location
      WechatRequest.new.send_text(to_user: uid, body: '正在获取地址, 请稍后...')
      raise 'location not set'
    end
    wuser = WechatUser.find_by_open_id(uid)
    WechatRequest.new.send_text(to_user: wuser.open_id, body: '定位服务已开启, 您可以回复k或者K开始旅途, 到达目的地后回复e或者E结束旅程, 请全程保持与服务号对话状态, 我们会记录您的旅途, 并为您推荐房源')
    REDIS.setex("#{uid}:wait_input", 2 * 3600, 'start_my_way')
    # do something
  end

  def send_region_article(wuser)
    article = [{title: "湾区地图导购",
                body: "点击文章开启导购模式",
                picurl: File.join(SERVER_HOST, 'bay_area_map.jpeg'),
                url: "#{CLIENT_HOST}/region_tutorial?uid=#{wuser.id}"}]
    WechatRequest.new.send_articles(to_user: wuser.open_id, body: article)
  end
end
