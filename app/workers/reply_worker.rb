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
        when 'home_map'
          article = [{title: "我们为您生成了地图看房连接",
                      body: "点击文章打开地图，查看您感兴趣的房子",
                      picurl: File.join(SERVER_HOST, 'bay_area_map.jpeg'),
                      url: File.join(CLIENT_HOST, "homeMap?ids=#{reference_id}")}]

          WechatRequest.new.send_articles(to_user: wid, body: article)
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
          body = '您可以上传二维码以便经纪人与您取得联系'
          WechatRequest.new.send_text(to_user: wid, body: body)
        when 'need_agent'
          body = '您可以回复经纪人编号获取联系方式，我们的经纪人也会尽快与您取得联系'
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
end