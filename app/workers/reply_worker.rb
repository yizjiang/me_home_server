# encoding: utf-8

class ReplyWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(wid, event, reference_id = nil)
    if wid
      body = ''
      case event
        when 'select_article'
          body = '您可以回复文章编号来推荐到您的主页'
          WechatRequest.new(true).send_text(to_user: wid, body: body)
        when 'region_tutorial'
          article = [{title: "湾区地图导购",
                      body: "点击文章开启导购模式",
                      picurl: File.join(SERVER_HOST, 'bay_area_map.jpeg'),
                      url: "#{CLIENT_HOST}/region_tutorial?uid=#{reference_id}"}]
          WechatRequest.new.send_articles(to_user: wid, body: article)
        when 'home_on_my_way'
          body = "您经过的坐标为 #{reference_id}"
          WechatRequest.new.send_text(to_user: wid, body: body)
        when 'home_map_with_my_location'
          location = REDIS.get("#{wid}:location")
          random_id = SecureRandom.hex
          cache_redis(random_id, 'home_map', reference_id)
          article = [{title: "我们在您的附近找到了#{reference_id.split(',').count}处房源",
                      body: "点击文章打开地图，查看您感兴趣的房子",
                      picurl: File.join(SERVER_HOST, 'bay_area_map.jpeg'),
                      url: File.join(CLIENT_HOST, "homeMap?rid=#{random_id}&loc=#{location}")}]

          WechatRequest.new.send_articles(to_user: wid, body: article)
        when 'home_map'
          random_id = SecureRandom.hex
          cache_redis(random_id, 'home_map', reference_id)
          article = [{title: "我们为您生成了#{reference_id.split(',').count}处房源的地图链接",
                      body: "点击文章打开地图，查看您感兴趣的房子",
                      picurl: File.join(SERVER_HOST, 'bay_area_map.jpeg'),
                      url: File.join(CLIENT_HOST, "homeMap?rid=#{random_id}")}]

          WechatRequest.new.send_articles(to_user: wid, body: article)
        when 'home_map_with_user'
          article = [{title: '我们在地图上标注了您感兴趣的房屋',
                      body: '请点击文章查看',
                      picurl: File.join(SERVER_HOST, 'bay_area_map.jpeg'),
                      url: File.join(CLIENT_HOST, "homeMap?uid=#{reference_id}")}]

          WechatRequest.new.send_articles(to_user: wid, body: article)
        when 'home_card'
          wechat_user = WechatUser.find(wid)
          wechat_user.user.listing_homes.each do |home|
            wechat_user.send_home_on_wechat(home.home_id, true)
          end
        when 'agent_card'
          agent = User.find(reference_id)
          extention = agent.agent_extention
          article = [{title: "#{extention.cn_name}希望为您服务,点击查看经纪人详情",
                      body: "#{extention.description}",
                      picurl: agent.wechat_user.head_img_url,
                      url: File.join(CLIENT_HOST, "agent/#{extention.agent_identifier}")}]

          WechatRequest.new.send_articles(to_user: wid, body: article)
        when 'listing_agent_card'
          agent = User.find(reference_id)
          extention = agent.agent_extention
          article = [{title: "#{extention.cn_name}是此房子的卖方经纪人，请点击经纪人头像查看二维码",
                      body: "#{extention.description}",
                      picurl: agent.wechat_user.head_img_url,
                      url: agent.qr_code}]

          WechatRequest.new.send_articles(to_user: wid, body: article)
        when 'upload_qrcode'
          REDIS.setex("#{wid}:wait_input", 600, 'upload_customer_qr_code')
          body = '小提示: 上传二维码能更方便经纪人与您取得联系。您可以随时点击下方菜单，我的觅家->我的二维码进行上传'
          WechatRequest.new.send_text(to_user: wid, body: body)
        when 'need_agent'
          body = '您可以点击经纪人头像查看详情 或 直接回复一位经纪人编号获取联系方式，我们的经纪人也会尽快与您取得联系'
          WechatRequest.new.send_text(to_user: wid, body: body)
        when 'submit_answer'
          body = '您可以回复经纪人编号获取联系方式.'
          WechatRequest.new.send_text(to_user: wid, body: body)
        when 'agent_request'
          body = '您可以输入需求编号进行回复'
          WechatRequest.new(true).send_text(to_user: wid, body: body)
        when 'potential_buyer'
          body = '您可以输入客户编号(用逗号或者空格分开)推送您的觅家名牌, 输入0推送全部'
          WechatRequest.new(true).send_text(to_user: wid, body: body)
        when 'response_agent_request'
          request = AgentRequest.find(reference_id)
          agent = User.find(request.to_user)
          name = agent.agent_extention.cn_name || agent.wechat_user.nickname
          body = "#{name}: #{request.response}"
          WechatRequest.new.send_text(to_user: wid, body: body)

          article = [{title: "#{name}希望为您服务",
                      body: '',
                      picurl: agent.qr_code,
                      url: agent.qr_code}]

          WechatRequest.new.send_articles(to_user: wid, body: article)

        when 'request_response'
          request = AgentRequest.find(reference_id)
          agent = User.find(request.to_user)
          name = agent.agent_extention.cn_name || agent.wechat_user.nickname
          body = "#{name}: #{request.response}"

          article = [{title: "#{name}希望为您服务",
                      body: '',
                      picurl: agent.qr_code,
                      url: agent.qr_code}]

          WechatRequest.new.send_articles(to_user: wid, body: article)
      end
    end
  end

  def cache_redis(wid, key, value)
    REDIS.setex("#{wid}:#{key}", 60 * 60 * 24, value.to_s)
  end
end