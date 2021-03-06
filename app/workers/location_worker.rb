# encoding: utf-8

class LocationWorker
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

    url = "http://dev.virtualearth.net/REST/v1/Locations/#{location}?o=json&includeEntityTypes=Postcode1&key=#{ACCESS_KEY}"
    response = Typhoeus.get(url)
    result = JSON.parse response.body
    if result = result['resourceSets'][0]['resources'][0]
      zipcode = result['address']['postalCode']
      wuser = WechatUser.find_by_open_id(uid)
      wuser.send_homes_to_wechat(zipcode, wuser.user.id)
    else
      WechatRequest.new.send_text(to_user: wuser.open_id, body: '对不起, 无法获取您当前在美国的地址。此功能暂时无法对身处国内的用户使用, 您可以通过地图导购了解湾区')
      send_region_article(wuser)
    end

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
