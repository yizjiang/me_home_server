# encoding: utf-8

#require '../../lib/wechat/response_command'

class WechatController < ApplicationController
  before_filter :get_message_from_params, :if => lambda { request.post? }

  METHOD_MAPPING = {'s' => :home_search,
                    'q' => :ask_question,
                    'a' => :need_agent,
                    'u' => :update_search,
                    'U' => :update_search,
                    'cq' => :customer_questions,
                    'pc' => :agent_request,
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
                    'meejia_qr_code' => :meejia_qr_code

  }

  def collect_data
    p params
    #redirect_to 'http://www.google.com'
  end

  def auth
    render text: params['echostr']
  end

  def message
    response = if methond_sym = METHOD_MAPPING[@msg_hash[:body]]
                 send(methond_sym)
               elsif (service_type = cached_input(:wait_input))
                 delete_redis(:wait_input)
                 @user_input = @msg_hash[:body]
                 send(service_type.to_sym)
               else
                 default_response
               end
    render xml: response
  end

  private

  def agent_assist
    @msg_hash[:items] = [{title: "觅家竭诚邀请中国的房产经纪人和具有美国执照的经纪人联手一起为客户找到满意的家和地产投资。具体的合作协议和申请手续还在准备中。如果您有意项和建议，请加二维码联系。",
                          body: '',
                          pic_url: "#{SERVER_HOST}/agent_assitant.jpg",
                          url: "#{SERVER_HOST}/agent_assitant.jpg"}]
    article_response
  end

  def get_message_from_params
    p "xxx #{params}"
    body = case params['xml']['MsgType']
             when 'text'
               params['xml']['Content']
             when 'image'
               params['xml']['PicUrl']
             when 'event'
               if  params['xml']['Event'] == 'SCAN'
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
               else
                 params['xml']['EventKey']
               end
             else
               ''
           end

    @msg_hash = {from_username: params['xml']['FromUserName'],
                 to_username: params['xml']['ToUserName'],
                 body: body}
    @wechat_user = WechatUser.find_or_initialize_by_open_id(@msg_hash[:from_username])
  end

  def default_response
    searches = @msg_hash[:body].split(',').map do |region|
      Search.new(regionValue: region)
    end

    homes = Home.search(searches, 10, Time.at(-284061600))
    if (homes.count > 0)
      latest = homes.map { |h| h.last_refresh_at }.max + 1
      @wechat_user.update_attributes(search: {regionValue: @msg_hash[:body], priceMin: '', priceMax: ''}.to_json, last_search: latest, search_count: (@wechat_user.search_count || 0) + 1)
      @msg_hash[:items] = home_search_items(homes)
      article_response
    else
      @msg_hash[:body] = '对不起，以下消息 ' + @msg_hash[:body] + ' 无法自动回复，稍后会有人与您联系'
      text_response
    end
  end

  def loan_agent
    @msg_hash[:body] = '服务暂时没有开通'
    text_response
  end

  def ask_question
    set_redis(:wait_input, :submit_question)
    @msg_hash[:body] = '请输入您想问问的问题'
    text_response
  end

  def submit_question
    Question.create(open_id: @msg_hash[:from_username], text: @msg_hash[:body])
    @msg_hash[:body] = '问题已提交，您会在24小时内收到解答'
    text_response
  end

  def upload_agent_qr_code
    user = @wechat_user.user
    user.update_attributes(qr_code:  @msg_hash[:body])
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

    if @from_search
      confirm_string = "欢迎#{@wechat_user.nickname}关注觅家\n 您可以访问#{CLIENT_HOST}查看更多精彩内容"
    else
      confirm_string = "欢迎#{@wechat_user.nickname}登陆觅家\n 请点击网页上的确认键 或输入如下Email和密码: #{user.email}/meejia2016 完成登陆。"
    end

    REDIS.setex('wechat_login', 30, TicketGenerator.encrypt_uid(uid))     #TODO
    @msg_hash[:body] = confirm_string
    text_response
  end

  def update_qr
    set_redis(:wait_input, :upload_agent_qr_code)
    @msg_hash[:body] = '请上传新的二维码联系方式'
    text_response
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
      extention = AgentExtention.create(user_id: user.id, agent_identifier: user.username, license_id: 'xxx')
      user.agent_extention_id = extention.id
      user.save
      set_redis(:wait_input, :agent_license, 60 * 60)
      @msg_hash[:body] = "感谢您选择成为觅家经纪人，请输入您的经纪人序列号进行验证"
      text_response
    end
  end


  def agent_license
    extention = @wechat_user.user.agent_extention
    if extention
      extention.update_attributes(license_id: @msg_hash[:body])
    end
    set_redis(:wait_input, :upload_agent_qr_code, 60 * 60)
    @msg_hash[:body] = "经纪人序列号已保存，请上传您的二维码联系方式以便我们为您联系客户"
    text_response
  end

  def create_user
    username = @wechat_user.nickname.parameterize.underscore
    while User.where('username = ?', username).pluck(:username).length > 0
      username = username + Random.rand(1000).to_s
    end

    user = User.new(email: "#{username}@meejia.com", username: username, password: 'meejia2016')
    user.save(validate: false)
    user
  end

  def customer_questions
    question = Question.unanswered(@wechat_user.user_id, Time.now - 3600).first
    if question
      set_redis(:wait_input, :answer_question, 3600)
      set_redis(:answer_question, question.id)
      username = if open_id = question.open_id
                   WechatUser.find_by_open_id(open_id).nickname
                 else
                   'xxx'
                 end
      @msg_hash[:body] = "#{username}提问: #{question.text}"
      text_response
    else
      @msg_hash[:body] = "目前没有客户问题"
      text_response
    end

  end

  def answer_question
    question = Question.find(cached_input(:answer_question).to_i)
    delete_redis(:answer_question)
    question.create_answer(@msg_hash[:body], WechatUser.find_by_open_id(@msg_hash[:from_username]).user_id)
    @msg_hash[:body] = "回复已提交"
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
    @msg_hash[:body] = "经纪人#{User.find(@agent_id).agent_extention.agent_identifier}非常荣幸能为您服务。您可以输入如下Email和密码: #{user.email}/meejia2016 登录meejia.com"
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
    agent = AgentExtention.find_by_agent_identifier(@msg_hash[:body]).user
    @wechat_user.update_attributes(agent_id: agent.id)
    @msg_hash[:items] = [{title: "#{agent.wechat_user.nickname}非常荣幸为您服务",
                          body: '点击二维码查看经纪人页面',
                          pic_url: agent.qr_code,
                          url: "#{CLIENT_HOST}/agent/#{@msg_hash[:body]}"}]
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
        {title: "#{user.nickname} 城市：#{search['regionValue']} 价格: #{search['priceMin']} - #{search['priceMax']} 累计搜索:#{user.search_count}次",
         body: '',
         pic_url: user.head_img_url,
         url: "#{SERVER_HOST}/agent/set_search?uid=#{@wechat_user.user_id}&cid=#{user.id}"}
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

  def agent_page
    ticket = TicketGenerator.encrypt_uid(@wechat_user.user_id)
    @msg_hash[:items] = [{title: "请点击您的头像设置您的主页",
                          body: '',
                          pic_url: @wechat_user.head_img_url,
                          url: "#{CLIENT_HOST}?ticket=#{ticket}#/agent"}]
    article_response
  end

  def update_search
    ticket = TicketGenerator.encrypt_uid(@wechat_user.user_id)

    if search = @wechat_user.search
      title = ''
      search = JSON.parse(search)
      mapping = {regionValue: '地区', bedNum: '房间数', priceMin: '最低价', priceMax: '最高价'}

      search.each do |k,v|
        title += "#{mapping[k.to_sym]}: #{v}, " if mapping.include?(k.to_sym)
      end

      @msg_hash[:items] = [{title: title,
                            body: '请点击您的头像设置智能搜索条件',
                            pic_url: @wechat_user.head_img_url,
                            url: "#{CLIENT_HOST}?ticket=#{ticket}#/dashboard"}]
      article_response
    else
      @msg_hash[:items] = [{title: "请点击您的头像设置智能搜索条件",
                            body: '',
                            pic_url: @wechat_user.head_img_url,
                            url: "#{CLIENT_HOST}?ticket=#{ticket}#/dashboard"}]
      article_response
    end
  end

  def my_favorite
    homes = User.find(@wechat_user.user_id).homes
    if homes.count > 0
      @msg_hash[:items] = home_search_items(homes)
      article_response
    else
      @msg_hash[:body] = '您还没有红心房源'
      text_responsen
    end
  end

  def home_search
    last_search = @wechat_user.last_search
    search = if search = @wechat_user.search
               JSON.parse(search)
             else
               {}
             end

    if !search.empty?
      searches = search['regionValue'].split(',').map do |region|
        Search.new(regionValue: region, priceMin: search['priceMin'], priceMax: search['priceMax'], bedNum: search['bedNum'])
      end

      homes = Home.search(searches, 10, last_search || Time.at(-284061600)) # fair divide?
      if (homes.count > 0)
        latest = homes.map { |h| h.last_refresh_at }.max + 1
        @wechat_user.update_attributes(last_search: latest, search_count: (@wechat_user.search_count || 0) + 1)
        @msg_hash[:items] = home_search_items(homes)
        article_response
      else
        @wechat_user.update_attributes(search_count: (@wechat_user.search_count || 0) + 1)
        @msg_hash[:body] = "您所搜索的地区还没有房源更新, 请回复u或点击更新搜索获取更多房源"
        text_response
      end

    else
      ticket = TicketGenerator.encrypt_uid(@wechat_user.user_id)
      @msg_hash[:items] = [{title: "请点击您的头像设置智能搜索条件",
                           body: '',
                           pic_url: @wechat_user.head_img_url,
                           url: "#{CLIENT_HOST}/?ticket=#{ticket}#/dashboard"}]
      article_response
    end
  end

  def agent_request  #TODO
    #@msg_hash[:body] = "User #{AgentRequest.last.open_id} request agent help in #{AgentRequest.last.region} area"
    @msg_hash[:body] = "目前没有客户有经纪人需求"
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
    agents = User.where('agent_extention_id is NOT NULL').includes(:agent_extention, :wechat_user).limit(10)
    agents.map do |agent|
      {title: "#{agent.wechat_user.try(:nickname)}",
       body: '',
       pic_url: "#{agent.wechat_user.try(:head_img_url)}",
       url: "#{CLIENT_HOST}/agent/#{agent.agent_extention.try(:agent_identifier)}"}
    end
  end

  def home_search_items(homes)
    ticket = TicketGenerator.encrypt_uid(@wechat_user.user_id)
    homes.map do |home|
      {title: "位于#{home.addr1} #{home.city}的 #{home.bed_num} 卧室 #{home.home_type}，售价：#{home.price}美金",
       body: 'nice home',
       pic_url: "#{CDN_HOST}/photo/#{home.images.first.try(:image_url) || 'default.jpeg'}",
       url: "#{CLIENT_HOST}/?ticket=#{ticket}#/home_detail/#{home.id}"}
    end
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
