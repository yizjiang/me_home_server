class SearchWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  sidekiq_retry_in do |count|
    1 * (count + 1)
  end

  sidekiq_retries_exhausted do |msg|
    p 'xxx'
    p msg.inspect
    WechatRequest.new.send_text(to_user: msg['args'][0], body: 'can not acquire location')
  end

  def perform(uid)
    location = REDIS.get("#{uid}:location")
    raise 'location not set' unless location
    url = "http://dev.virtualearth.net/REST/v1/Locations/#{location}?o=json&includeEntityTypes=Postcode1&key=AjVrfYUU-6_5NnEHSjCxZ16XAJHyu0-J42p16WXCld6F52NujvxQ2iRV1X3UQeQs"
    response = Typhoeus.get(url)
    result = JSON.parse response.body
    zipcode = result['resourceSets'][0]['resources'][0]['address']['postalCode']
    WechatUser.find_by_open_id(uid).send_homes_on_wechat('regionValue' => zipcode.to_s)
    # do something
  end
end