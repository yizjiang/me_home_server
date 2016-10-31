# encoding: utf-8

class WechatController < ApplicationController
  before_filter :get_message_from_params, :if => lambda { request.post? }
  before_filter :check_agent_permission, :if => lambda { params['xml'] && params['xml']['ToUserName'] == AGENT_ACCOUNT_ID &&
    ['my_client', 'buyer', 'agent_request', 'cq', 'set_agent_page', 'articles'].include?(@msg_hash[:body].downcase)
                                                       }

  METHOD_MAPPING = {'s' => :home_search,
                    'q' => :ask_question,
                    'a' => :need_agent,
                    'u' => :update_search,
                    'U' => :update_search,
                    'n' => :next_homes,
                    'cq' => :customer_questions,
                    'pc' => :agent_request,
                    'agent_request' => :agent_request,
                    'follow_agent' => :followed_by_agent,
                    'my_client' => :my_client,
                    'agent_follow' => :agent_follow,
                    'agent_assist' => :agent_assist,
                    'agent_login' => :agent_login,
                    'update_qr' => :update_qr,
                    'update_identifier' => :update_identifier,
                    'license' => :agent_license,
                    'login' => :login,
                    'fav' => :my_favorite,
                    'l' => :loan_agent,
                    'agent_page' => :agent_page,
                    'set_agent_page' => :set_agent_page,
                    'meejia_qr_code' => :meejia_qr_code,
                    'my_login' => :my_login,
                    'report_location' => :report_location,
                    'home_here' => :home_here,
                    'buyer' => :potential_buyer,
                    'articles' => :latest_articles,
                    'send_home_card' => :send_home_card,
                    'home_card' => :home_card,
                    'my_agent' => :my_agent,
                    'game_login' => :game_login,
                    'client_articles' => :client_articles
  }

  def collect_data
    p params
    #redirect_to 'http://www.google.com'
  end

  def auth
    render text: params['echostr']
  end

  def message
    if !@can_access
      @msg_hash[:body] = '请先回复您的经纪人编号，在尝试此功能'
      set_redis(:wait_input, :update_agent_license, 60 * 60)
      response = text_response
    else
      response = if methond_sym = METHOD_MAPPING[@msg_hash[:body].downcase]
                   send(methond_sym)
                 elsif (service_type = cached_input(:wait_input))
                   delete_redis(:wait_input)
                   @user_input = @msg_hash[:body]
                   send(service_type.to_sym)
                 else
                   default_response
                 end
    end
    if response
      render xml: response
    else
      render nothing: true
    end
  end

  private

  def agent_assist
    @msg_hash[:items] = [{title: "觅家竭诚邀请中国的房产经纪人和具有美国执照的经纪人联手一起为客户找到满意的家和地产投资。具体的合作协议和申请手续还在准备中。如果您有意项和建议，请加二维码联系。",
                          body: '',
                          pic_url: "#{SERVER_HOST}/agent_assitant.jpg",
                          url: "#{SERVER_HOST}/agent_assitant.jpg"}]
    article_response
  end

  def home_card
    if @wechat_user.user.listing_homes.count > 0
      ReplyWorker.perform_async(@wechat_user.id, 'home_card')
      @msg_hash[:body] = '您可以分享此房屋名牌'
    else
      @msg_hash[:body] = '对不起，没有找到您待售的房源'
    end
    text_response
  end

  def game_login
    REDIS.setex(@uid, 60 * 60, @wechat_user.id)
    @msg_hash[:body] = '您可以查看房屋后分享'
    text_response
  end

  def send_home_card
    home = Home.find(@home_id)

    if Home::OTHER_PROPERTY_TYPE.include?(home.meejia_type)
      title = "#{home.city}的#{home.home_cn.try(:lot_size)}#{home.home_cn.try(:home_type) || home.meejia_type}，#{home.price / 10000}万美金"
    else
      title = "#{home.city}的#{home.bed_num}卧室#{home.home_cn.try(:home_type) || home.meejia_type}，#{home.price / 10000}万美金"
    end

    body = {title: title,
     body: home.home_cn.try(:short_desc) || '绝对超值',
     pic_url: "#{CDN_HOST}/photo/#{home.images.first.try(:image_url) || 'default.jpeg'}",
     url: "#{CLIENT_HOST}/home/#{home.id}/?agent_id=#{@agent_id}"}

    ReplyWorker.perform_async(@wechat_user.open_id, 'listing_agent_card', @agent_id)

    @msg_hash[:items] = [body]
    article_response
  end

  def get_message_from_params
    body = case params['xml']['MsgType']
             when 'text'
               params['xml']['Content']
             when 'image'
               @media_id = params['xml']['MediaId']
               params['xml']['PicUrl']
             when 'voice'
               params['xml']['MediaId']
             when 'event'
               if  params['xml']['Event'] == 'SCAN'
                 if params['xml']['EventKey'].start_with?('h')
                   home_id, @agent_id = params['xml']['EventKey'].split('a')
                   @home_id = home_id[1..-1]
                   'send_home_card'
                 elsif params['xml']['EventKey'].start_with?('login')
                   @uid = params['xml']['EventKey'][6..-1]
                   'game_login'
                 else
                   @agent_id = params['xml']['EventKey'].to_i/10
                   event_id = params['xml']['EventKey'].to_i % 10
                   if event_id == 1
                     'follow_agent'
                   elsif event_id == 0
                     'agent_follow'
                   elsif event_id == 3
                     if params['xml']['ToUserName'] == ACCOUNT_ID
                       'login'
                     else
                       'agent_login'
                     end
                   end
                 end

               elsif params['xml']['Event'] == 'subscribe'
                 @from_search = false
                 @agent_id = params['xml']['EventKey'][8..-1].to_i/10
                 event_id = params['xml']['EventKey']
                 event_id = event_id[8..-1].to_i % 10  if event_id.present?
                 if event_id == 1
                   'follow_agent'
                 elsif event_id == 0
                   'agent_follow'
                 elsif event_id == 3
                   if params['xml']['ToUserName'] == ACCOUNT_ID
                     'login'
                   else
                     'agent_login'
                   end
                 else
                   @from_search = true
                   if params['xml']['ToUserName'] == ACCOUNT_ID
                     'login'
                   else
                     'agent_login'
                   end
                 end
               elsif params['xml']['Event'] == 'LOCATION'
                 'report_location'
               else
                 params['xml']['EventKey']
               end
             else
               ''
           end
    @msg_hash = {from_username: params['xml']['FromUserName'],
                 to_username: params['xml']['ToUserName'],
                 body: body,
                 type: params['xml']['MsgType']}
    @wechat_user = WechatUser.find_or_initialize_by_open_id(@msg_hash[:from_username])
    @can_access = true
  end

  def check_agent_permission
    if AgentExtention.where(user_id: @wechat_user.user.id).where("status != 'Inactive'").present?
      @can_access = true
    else
      @can_access = false
    end
  end

  def default_response
    homes = Home.search_by_address(@msg_hash[:body])
    if homes.empty?
      @msg_hash[:body] = '对不起，没有找到位于 ' + @msg_hash[:body] + ' 的房源'
      text_response
    else
      home_result(homes)
    end
  end

  def home_search
    search = if search = @wechat_user.search
               JSON.parse(search)
             else
               {}
             end

    if !search.empty?
      searches = search['regionValue'].split(',').map do |region|
        Search.new(regionValue: region, priceMin: search['priceMin'], priceMax: search['priceMax'], bedNum: search['bedNum'], home_type: search['home_type'])
      end

      homes = Home.search(searches).shuffle
      ReplyWorker.perform_async(@wechat_user.open_id, 'home_map', homes.map(&:id).join(','))
      home_result(homes)
    else
      if cached_input('quick_search')
        homes = []
        HOT_AREAS.sample(3).each do |area|
          homes += Home.search(Search.new(regionValue: area), 3)
        end
        home_result(homes)
      else
        SearchWorker.perform_async(@wechat_user.id)
        set_redis('quick_search', true, 3600)
        body = [{title: "点击头像设置搜索条件",
                 body: '为了让您更了解美国房产，我们也为您推送了热门房屋，您可以持续点击查看下一页',
                 pic_url: @wechat_user.head_img_url,
                 url: "#{CLIENT_HOST}/quick_search/?wid=#{@wechat_user.id}"}]
        @msg_hash[:items] = body
        article_response
      end
    end
  end

  def client_articles
    @msg_hash[:items] = Article.last(10).map do |item|
      doc = Nokogiri::HTML(item.content)
      pic_url = doc.xpath("//img").select{|d| d['src'].end_with?('jpeg')}[0]['src']

      {title: item.title,
       body: item.digest,
       pic_url: pic_url,
       url: item.url}
    end

    article_response
  end

  def latest_articles
    set_redis(:wait_input, :select_article)
    ReplyWorker.perform_async(@wechat_user.open_id, 'select_article')
    @msg_hash[:items] = article_items(AgentArticle.last(10))
    article_response
  end

  def select_article
    page_config = @wechat_user.user.agent_extention.page_config || "{}"
    page_config = JSON.parse page_config
    page_config[:article_id] = @msg_hash[:body]
    @wechat_user.user.agent_extention.update_attributes(page_config: page_config.to_json)
    @msg_hash[:body] = '已成功推荐到您的主页'
    text_response
  end

  def article_items(articles)
    articles.map do |item|
      {title: "编号#{item.id}: #{item.title}",
       body: item.digest,
       pic_url: item.content[/src="(.*?)"/i,1],
       url: item.url}
    end
  end

  def next_homes
    home_ids = cached_input('next_ids')
    if home_ids
      home_ids = home_ids.split(',')
      homes = Home.where('id in (?)', home_ids)
      home_result(homes)
    else
      @msg_hash[:body] = '您还未搜索, 或者搜索地区没有更多房源'
      text_response
    end
  end

  def home_result(homes)
    more_home = 0
    if (homes.count > 0)
      if homes.length > 10
        more_home = homes.length - 9
        showing_ids = homes[0..8].map(&:id)
        set_redis('next_ids', (homes[9..-1].map(&:id)).join(','), 300)
        homes = homes[0..8]
      else
        delete_redis('next_ids')
      end

      latest = homes.map { |h| h.last_refresh_at }.max + 1
      @wechat_user.update_attributes(last_search: latest, search_count: (@wechat_user.search_count || 0) + 1)
      @msg_hash[:items] = home_search_items(homes, more_home)
      article_response
    else
      @msg_hash[:body] = '对不起，以下地区 ' + @msg_hash[:body] + ' 没有房源更新'
      text_response
    end
  end

  def report_location
    lat, long = params['xml']['Latitude'], params['xml']['Longitude']
    set_redis('location', "#{lat},#{long}" , 300)
    nil
  end

  def home_here
    LocationWorker.perform_async(@msg_hash[:from_username])
    @msg_hash[:body] = '正在获取地址，请稍后....'
    text_response
  end

  def loan_agent
    @msg_hash[:body] = '服务暂时没有开通'
    text_response
  end

  def ask_question
    set_redis(:wait_input, :submit_question)
    @msg_hash[:body] = '请输入或语音留言您想问的问题。(我们暂时只能接受一条消息留言)'
    text_response
  end

  def submit_question
    case @msg_hash[:type]
      when 'text'
        Question.create(open_id: @msg_hash[:from_username], text: @msg_hash[:body])
      else
        media = Question.create_with_media(open_id: @msg_hash[:from_username], text: '该问题是语音消息', media_id: @msg_hash[:body])
        MediaWorker.perform_async(@wechat_user.id, media.id, false, false)
    end

    @msg_hash[:body] = '问题已提交，我们的经纪人会尽快为您解答'
    text_response
  end

  def upload_customer_qr_code
     QrcodeWorker.perform_async(@media_id, @wechat_user.id)
     @msg_hash[:body] = '已上传'
     text_response
  end

  def upload_agent_qr_code
    user = @wechat_user.user
    user.update_attributes(qr_code: @msg_hash[:body])
    uid = user.id
    expect_file = "public/agents/#{uid}1.png"
    unless File.exist?(expect_file)
      WechatRequest.new.generate_qr_code("#{uid}1")
    end

    @msg_hash[:items] = [{title: "经纪人#{@wechat_user.nickname}为您觅家",
                          body: '您可以分享如下二维码给您的现有或潜在客户，您可以通过觅家跟踪客户的购房进展',
                          pic_url:"#{SERVER_HOST}/agents/#{uid}1.png",
                          url: "#{SERVER_HOST}/agents/#{uid}1.png"}]
    article_response
  end

  def login
    set_wechat_user_info
    uid = @wechat_user.user_id
    if uid.nil? || uid == 0
      user = create_user
      @wechat_user.user_id = user.id
    else
      user = User.find(uid)
    end
    @wechat_user.save

    uid ||= @wechat_user.user_id

    unless @wechat_user.qrcode
      ReplyWorker.perform_async(@wechat_user.open_id, 'upload_qrcode')
    end

    if @from_search
      confirm_string = "欢迎#{@wechat_user.nickname}关注觅家"
    else
      confirm_string = "欢迎#{@wechat_user.nickname}登陆觅家\n 请点击网页上的确认键 或输入如下Email和密码: #{user.email}/meejia2016 完成登陆。"
    end

    REDIS.setex('wechat_login', 30, TicketGenerator.encrypt_uid(uid))     #TODO
    @msg_hash[:body] = confirm_string
    text_response
  end

  def update_qr
    if @wechat_user.user.agent_extention
      set_redis(:wait_input, :upload_agent_qr_code)
      @msg_hash[:body] = '请上传新的二维码联系方式'
      text_response
    else
      set_redis(:wait_input, :upload_customer_qr_code)
      if qrcode = @wechat_user.qrcode
        @msg_hash[:items] = [{title: "您已上传二维码,您可以上传进行更新",
                              body: '',
                              pic_url: qrcode,
                              url: qrcode}]
        article_response
      else
        @msg_hash[:body] = "请上传您的二维码。\n\n不知道如何上传?\n简单，您只需要发送二维码图片到当前公众号。\n\n不知道如何获取?\n简单, 返回至微信菜单 点击 菜单我->最上方头像-> My QR code -> 右上方 ... -> Save Image -> 保存至手机相册"
        text_response
      end
    end

  end

  def update_identifier
    set_redis(:wait_input, :update_identifier_record)
    @msg_hash[:body] = "您现在的编码是 #{@wechat_user.user.agent_extention.agent_identifier}, 请输入您想要更新的编码"
    text_response
  end

  def agent_login
    set_wechat_user_info(true)
    uid = @wechat_user.user_id
    if uid.nil? || uid == 0
      user = create_user
      @wechat_user.user_id = user.id
      @wechat_user.agent_id = user.id
    else
      user = User.find(uid)
    end
    @wechat_user.save
    extention = AgentExtention.find_by_user_id(user.id)
    if extention
      uid ||= user.id

      REDIS.setex('wechat_login', 30, TicketGenerator.encrypt_uid(uid))

      @msg_hash[:body] = "您登陆的Email和密码是: #{user.email}/meejia2016，经纪人编码是#{extention.agent_identifier}, 请点击网页上的确定键完成登陆"
      text_response
    else
      user.agent_extention_id = PENDING_LISCENCE
      user.save
      set_redis(:wait_input, :agent_license, 60 * 60)
      @msg_hash[:body] = "感谢您选择成为觅家经纪人，请输入您的经纪人序列号"
      text_response
    end
  end

  def update_agent_license
    extention = AgentExtention.find_by_user_id(@wechat_user.user.id)
    extention.update_attributes(license_id: @msg_hash[:body], status: 'Active')
    @msg_hash[:body] = "经纪人序列号已保存"
    text_response
  end

  def agent_license
    extention = AgentExtention.find_or_create_by_license_id(@msg_hash[:body])
    @wechat_user.user.update_attributes(agent_extention_id: extention.id)
    extention.update_attributes(user_id:  @wechat_user.user.id, status: 'Active')
    AgentFetcher.perform_async(extention.id, @msg_hash[:body])
    set_redis(:wait_input, :upload_agent_qr_code, 60 * 60)
    @msg_hash[:body] = "经纪人序列号已保存，请上传您的二维码联系方式以便我们为您联系客户"
    text_response
  end

  def create_user
    username = @wechat_user.nickname.parameterize.underscore
    while User.where('username = ?', username).pluck(:username).length > 0
      username = username + Random.rand(1000).to_s
    end

    user = User.new(email: "#{username}@meejia.cn", username: username, password: 'meejia2016')
    user.save(validate: false)
    user
  end

  def customer_questions
    #TODO list questions
    question = Question.unanswered(@wechat_user.user_id, Time.now - 3600).first
    if question
      set_redis(:wait_input, :answer_question, 3600)
      set_redis(:answer_question, question.id)
      username = if open_id = question.open_id
                   WechatUser.find_by_open_id(open_id).nickname
                 else
                   'xxx'
                 end
      body = "#{username}提问: #{question.text}"
      if media = question.media
        body += ',正在获取。'
        MediaWorker.perform_async(@msg_hash[:from_username], media.id, false, true)
      end
      body += "\n请直接回复文字或语音答复(暂时只支持一条)。如果客户满意，我们会推送您的二维码联系方式。"
      @msg_hash[:body] = body
      text_response
    else
      @msg_hash[:body] = "目前没有客户问题"
      text_response
    end

  end

  def answer_question
    question = Question.find(cached_input(:answer_question).to_i)
    delete_redis(:answer_question)

    case @msg_hash[:type]
      when 'text'
        question.create_answer(@msg_hash[:body], @wechat_user.user_id)
        ReplyWorker.perform_async(question.open_id, 'submit_answer')
      else
        media = question.create_answer_with_media(@msg_hash[:body], @wechat_user.user_id)
        MediaWorker.perform_async(question.open_id, media.id, true, true)
    end
    @msg_hash[:body] = "回答已提交"
    text_response
  end

  def agent_follow
    @wechat_user.agent_id = @agent_id
    @wechat_user.user_id = @agent_id  
    set_wechat_user_info
    @wechat_user.save
    user = @wechat_user.user
    if user.qr_code
      uid = user.id
      expect_file = "public/agents/#{uid}1.png"
      unless File.exist?(expect_file)
        WechatRequest.new.generate_qr_code("#{uid}1")
      end
      @msg_hash[:items] = [{title: "恭喜您成为觅家经纪人，您登陆的Email和密码是: #{user.email}/meejia2016，经纪人编码是#{user.agent_extention.agent_identifier}",
                            body: '您可以分享如下二维码给您的现有或潜在客户，您可以通过觅家跟踪客户的购房进展',
                            pic_url:"#{SERVER_HOST}/agents/#{uid}1.png",
                            url: "#{SERVER_HOST}/agents/#{uid}1.png"}]
      article_response
    else
      set_redis(:wait_input, :upload_agent_qr_code)
      @msg_hash[:body] = "请上传您的二维码完善联系方式"
      text_response
    end
  end

  def my_agent
    agent_id = @wechat_user.agent_id
    if agent_id
      agent = User.find(agent_id)
      @msg_hash[:items] = [{title: "#{agent.agent_extention.cn_name || agent.wechat_user.nickname}非常荣幸为您服务",
                            body: '',
                            pic_url: agent.qr_code,
                            url: agent.qr_code}]
      article_response
    else
      @msg_hash[:body] = '您还没有选择经纪人，请点击专业经纪人->购房经纪人选择'
      text_response
    end
  end

  def followed_by_agent
    @wechat_user.agent_id = @agent_id
    set_wechat_user_info
    unless uid = @wechat_user.user_id
      user = create_user
      @wechat_user.user_id = user.id
    else
      user = User.find(uid)
    end
    @wechat_user.save
    ReplyWorker.perform_async(@wechat_user.open_id, 'agent_card', @agent_id)
    @msg_hash[:body] = "您可以输入如下Email和密码: #{user.email}/meejia2016 登录meejia.cn"
    text_response
  end

  def set_wechat_user_info(is_agent = false)
    unless  @wechat_user.nickname
      user_info = WechatRequest.new(is_agent).fetch_user_info(@msg_hash[:from_username])
      @wechat_user.nickname = user_info['nickname']
      @wechat_user.head_img_url = user_info['headimgurl']
    end
  end

  def like_agent
    agent = User.find(@user_input)
    @wechat_user.update_attributes(agent_id: agent.id)
    @msg_hash[:items] = [{title: "#{agent.agent_extention.cn_name || agent.wechat_user.nickname}非常荣幸为您服务",
                          body: '',
                          pic_url: agent.qr_code,
                          url: agent.qr_code}]
    article_response
  end

  def my_client
    if  @wechat_user.agent_id.to_i == @wechat_user.user_id
      @msg_hash[:items] =
        WechatUser.where("agent_id = ? AND agent_id != user_id", @wechat_user.user_id)
        .order('search_count DESC').limit(10)
      if  @msg_hash[:items].length > 0
        @msg_hash[:items] = @msg_hash[:items].map do |user|
        search = if user.search
                   JSON.parse(user.search)
                 else
                   {}
                 end
        {title: "#{user.nickname} 城市：#{search['regionValue']} 价格: #{search['priceMin']} - #{search['priceMax']}万美元 累计搜索:#{user.search_count}次",
         body: '',
         pic_url: user.head_img_url,
         url: "#{CLIENT_HOST}/quick_search/?wid=#{user.id}&from_agent=true"}
        end
        article_response
      else
        @msg_hash[:body] = "您目前还没有客户，请分享二维码发展客户"
        text_response
      end

    else
      @msg_hash[:body] = "您目前并不是经纪人，请登录觅家网站完善信息"
      text_response
    end
  end

  def need_agent
    @msg_hash[:items] = agent_search_items
    article_response
  end

  def agent_confirm
    region = if (@msg_hash[:body] == 'Y' || @msg_hash[:body] == 'y')
               cached_input(:agent_confirm)
             else
               @msg_hash[:body]
             end
    AgentRequest.where(open_id: @msg_hash[:from_username], status: 'open', region: region).first_or_create
    @msg_hash[:body] = '您的需求已提交，我们会在24小时内给您回复'
    delete_redis(:agent_confirm)
    text_response
  end

  def update_search
    if search = @wechat_user.search
      title = ''
      search = JSON.parse(search)

      searches = search['regionValue'].split(',').map do |region|
        Search.new(regionValue: region, priceMin: search['priceMin'], priceMax: search['priceMax'], bedNum: search['bedNum'], home_type: search['home_type'])
      end

      home = Home.search(searches, 1).as_json(shorten: true).first

      if (search['home_type'] - Home::OTHER_PROPERTY_TYPE).length == 0
        title = "#{search['regionValue']}其他类型房产"
      else
        title = "#{search['regionValue']}多于#{search['bedNum']}卧室"
      end

      @msg_hash[:items] = [{title: "当前搜索:#{title}, 点击更新",
                            body: '',
                            pic_url: home.try(:[], 'images').try(:first).try(:image_url) || @wechat_user.head_img_url,
                            url: "#{CLIENT_HOST}/quick_search/?wid=#{@wechat_user.id}"}]
      article_response
    else
      @msg_hash[:items] = [{title: "点击设置智能搜索条件",
                            body: '',
                            pic_url: @wechat_user.head_img_url,
                            url: "#{CLIENT_HOST}/quick_search/?wid=#{@wechat_user.id}"}]
      article_response
    end
  end

  def my_favorite
    homes = User.find(@wechat_user.user_id).homes
    if homes.count > 0
      @msg_hash[:items] = home_search_items(homes)
      ReplyWorker.perform_async(@wechat_user.open_id, 'home_map_with_user', @wechat_user.user_id)
      article_response
    else
      @msg_hash[:body] = '您还没有红心房源'
      text_responsen
    end
  end

  def agent_page
    @msg_hash[:items] = [{title: "请点击您的头像查看主页",
                          body: '',
                          pic_url: @wechat_user.head_img_url,
                          url: "#{CLIENT_HOST}/agent/#{@wechat_user.user.agent_extention.agent_identifier}"}]
    article_response
  end

  def set_agent_page
    ticket = TicketGenerator.encrypt_uid(@wechat_user.user_id)
    @msg_hash[:items] = [{title: "请点击您的头像设置主页",
                          body: '',
                          pic_url: @wechat_user.head_img_url,
                          url: "#{CLIENT_HOST}/agent/#{@wechat_user.user_id}/setting"}]
    article_response
  end

  def visited_buyer

  end

  def potential_buyer
    ReplyWorker.perform_async(@wechat_user.open_id, 'potential_buyer')
    set_redis(:wait_input, :select_buyer)
    items = WechatUser.limit(10).order('last_search').where('qrcode is not null').where('agent_id = 0 OR agent_id is NULL')
    if items.length < 10
      items += WechatUser.limit(10).order('last_search').where('qrcode is null').where('agent_id = 0 OR agent_id is NULL')
    end
    @msg_hash[:items] = wechat_user_items(items)
    set_redis('select_buyer', items.map(&:user_id).join(','))
    article_response
  end

  def agent_request
    requests = AgentRequest.where(to_user: @wechat_user.user_id, status: 'open').limit(10)

    if requests.count < 10
      requests += AgentRequest.where(status: 'open').limit(10 - requests.count)
    end

    if requests.length > 0
      @msg_hash[:items] = agent_request_items(requests)
      set_redis(:wait_input, :select_ar)
      ReplyWorker.perform_async(@wechat_user.open_id, 'agent_request')
      article_response
    else
      @msg_hash[:body] = '目前没有房屋咨询'
      text_response
    end
  end

  def wechat_user_items(wechat_users)
    wechat_users.map do |wuser|
      title = if wuser.qrcode
                "编号#{wuser.user_id}: #{wuser.nickname}最近搜索了#{wuser.search_count.to_i}次, 点击获取二维码"
              else
                "编号#{wuser.user_id}: #{wuser.nickname}最近搜索了#{wuser.search_count.to_i}次, 希望能得到经纪人帮助"
              end
      {title: title,
       body: '',
       pic_url: wuser.head_img_url,
       url: wuser.qrcode
      }
    end
  end

  def answer_ar
    ar = AgentRequest.find(cached_input(:answer_ar).to_i)
    ar.update_attributes(status: 'close', response:  @msg_hash[:body])
    ReplyWorker.perform_async(User.find(ar.from_user).wechat_user.try(:open_id), 'response_agent_request', ar.id)
    @msg_hash[:body] = '已提交'
    text_response
  end

  def select_ar
    set_redis(:answer_ar, @msg_hash[:body], 60 * 60)
    set_redis(:wait_input, :answer_ar, 60 * 60)
    @msg_hash[:body] = '请输入您的回复'
    text_response
  end

  def select_buyer
    if @msg_hash[:body].to_i == 0
      wusers = cached_input(:select_buyer).split(',')
    else
     wusers = [@msg_hash[:body].to_i]
    end
    wusers = WechatUser.where('id in (?)', wusers)
    wusers.each do |wuser|
      ReplyWorker.perform_async(wuser.open_id, 'agent_card', @wechat_user.user_id)
    end

    @msg_hash[:body] = '已尝试发送您的觅家名片给选中用户'
    text_response
  end

  def text_response
    file_content = File.open(File.expand_path("./app/helpers/text_response.xml.erb"), "r").read
    ERB.new(file_content).result(binding)
  end

  def image_response
    file_content = File.open(File.expand_path("./app/helpers/image_response.xml.erb"), "r").read
    ERB.new(file_content).result(binding)
  end

  def article_response
    file_content = File.open(File.expand_path("./app/helpers/article_response.xml.erb"), "r").read
    ERB.new(file_content).result(binding)
  end

  def agent_search_items
    agents = User.where('agent_extention_id is NOT NULL').includes(:agent_extention, :wechat_user).limit(8)
    ReplyWorker.perform_async(@msg_hash[:from_username], 'need_agent')
    set_redis(:wait_input, :like_agent)

    agents.map do |agent|
      experience = if license_issued = agent.agent_extention.license_issue
                     diff = Date.today.year - license_issued.to_s.to_i
                     diff > 0 ? diff : 0.5
                   else
                     0.5
                   end
      {title: "编号#{agent.id}: #{agent.agent_extention.cn_name || agent.wechat_user.try(:nickname)}, 从业#{experience}年",
       body: "#{agent.agent_extention.description}",
       pic_url: "#{agent.wechat_user.try(:head_img_url)}",
       url: "#{CLIENT_HOST}/agent/#{agent.agent_extention.try(:agent_identifier)}"}
    end
  end

  def agent_request_items(requests)
    requests.map do |request|
      home = Home.find(request.request_context_id)
      {title: "编号#{request.from_user}: " + request.body % {detail: "#{home.addr1} #{home.city}的房源信息"},
       body: '点击图片查看',
       picurl: "#{CDN_HOST}/photo/#{home.images.first.try(:image_url) || 'default.jpeg'}",
       url: "#{CLIENT_HOST}/home/#{home.id}/?uid=#{@wechat_user.user_id}"
      }
    end
  end

  def home_search_items(homes, more_home = 0)
    ticket = TicketGenerator.encrypt_uid(@wechat_user.user_id)
    homes = homes.map do |home|

      if Home::OTHER_PROPERTY_TYPE.include?(home.meejia_type)
        title = "#{home.city}的#{home.home_cn.try(:lot_size)}#{home.home_cn.try(:home_type) || home.meejia_type}，#{home.price / 10000}万美金"
      else
        title = "#{home.city}的#{home.bed_num}卧室#{home.home_cn.try(:home_type) || home.meejia_type}，#{home.price / 10000}万美金"
      end

      {title: title,
       body: 'nice home',
       pic_url: "#{CDN_HOST}/photo/#{home.images.first.try(:image_url) || 'default.jpeg'}",
       url: "#{CLIENT_HOST}/home/#{home.id}/?uid=#{@wechat_user.user_id}"}
    end

    if more_home > 0
      homes[homes.length] = {
        title: "还有#{more_home}处房源, 请回复n或N查看下一页",
        pic_url: "#{CDN_HOST}/photo/default.jpeg",
        url: "#{CLIENT_HOST}/?ticket=#{ticket}#/"
      }
    end

    homes
  end

  def my_login
    user = @wechat_user.user
    @msg_hash[:body] = "您登陆的Email和密码是: #{user.email}/meejia2016"
    text_response
  end

  def meejia_qr_code
    uid = @wechat_user.user.id
    @msg_hash[:items] = [{title: '这是您的觅家二维码',
                          body: '您可以分享如下二维码给您的现有或潜在客户，您可以通过觅家跟踪客户的购房进展',
                          pic_url:"#{SERVER_HOST}/agents/#{uid}1.png",
                          url: "#{SERVER_HOST}/agents/#{uid}1.png"}]
     article_response
  end

  def set_redis(key, value, expired_time = 60)
    REDIS.setex("#{@msg_hash[:from_username]}:#{key}", expired_time, value.to_s)
  end

  def delete_redis(key)
    REDIS.del("#{@msg_hash[:from_username]}:#{key}")
  end

  def cached_input(type)
    REDIS.get("#{@msg_hash[:from_username]}:#{type}")
  end
end
