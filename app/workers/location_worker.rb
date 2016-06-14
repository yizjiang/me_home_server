# encoding: utf-8

class LocationWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  sidekiq_retry_in do |count|
    count
  end

  sidekiq_retries_exhausted do |msg|
    WechatRequest.new.send_text(to_user: msg['args'][0], body: '无法获取地址，请您 1.前往手机设置开启微信的位置服务. 2.允许公众号获取地址(您可以点击右上角菜单开启)')
  end

  def perform(uid)
    @uid = uid
    location = REDIS.get("#{uid}:location")
    raise 'location not set' unless location
    url = "http://dev.virtualearth.net/REST/v1/Locations/#{location}?o=json&includeEntityTypes=Postcode1&key=#{ACCESS_KEY}"
    response = Typhoeus.get(url)
    result = JSON.parse response.body
    zipcode = result['resourceSets'][0]['resources'][0]['address']['postalCode']
    wuser = WechatUser.find_by_open_id(uid)
    wuser.send_homes_to_wechat(zipcode, wuser.user.id)
    # do something
  end
end
