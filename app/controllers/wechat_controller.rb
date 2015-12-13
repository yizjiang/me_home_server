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
                    'login' => :login,
                    'fav' => :my_favorite,
                    'l' => :loan_agent

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
             when 'event'
               if  params['xml']['Event'] == 'SCAN'
                 @agent_id = params['xml']['EventKey'].to_i/10
                 event_id = params['xml']['EventKey'].to_i % 10
                 if event_id == 1
                   'follow_agent'
                 elsif event_id == 0
                   'agent_follow'
                 elsif event_id == 3
                   'login'
                 end
               elsif params['xml']['Event'] == 'subscribe'
                 @agent_id = params['xml']['EventKey'][8..-1].to_i/10
                 event_id = params['xml']['EventKey'][8..-1].to_i % 10
                 if event_id == 1
                   'follow_agent'
                 elsif event_id == 0
                   'agent_follow'
                 elsif event_id == 3
                   'login'
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


  def login
    set_wechat_user_info
    unless uid = @wechat_user.user_id
      user = create_user
      @wechat_user.user_id = user.id
    else
      user = User.find(uid)
    end
    @wechat_user.save

    uid ||= @wechat_user.user_id

    REDIS.setex('wechat_login', 30, TicketGenerator.encrypt_uid(uid))     #TODO
    @msg_hash[:body] = "欢迎#{@wechat_user.nickname}登陆觅家\n 请点击网页上的确认键完成登陆，或者输入如下Email和密码: #{user.email}/meejia101"
    text_response
  end

  def create_user
    username = @wechat_user.nickname.parameterize.underscore
    while User.where('username = ?', username).pluck(:username).length > 0
      username = username + Random.rand(1000).to_s
    end

    user = User.new(email: "#{username}@meejia.com", username: username, password: 'meejia101')
    user.save(validate: false)
    user
  end

  def customer_questions
    question = Question.unanswered(@wechat_user.user_id, Time.now - 3600).first
    if question
      set_redis(:wait_input, :answer_question)
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
    @msg_hash[:body] = "预祝经纪人#{User.find(@agent_id).agent_extention.agent_identifier}生意兴隆"
    text_response
  end

  def followed_by_agent
    @wechat_user.agent_id = @agent_id
    set_wechat_user_info
    @msg_hash[:body] = "经纪人#{User.find(@agent_id).agent_extention.agent_identifier}非常荣幸能为您服务"
    text_response
  end

  def set_wechat_user_info
    unless  @wechat_user.nickname
      user_info = WechatRequest.new.fetch_user_info(@msg_hash[:from_username])
      @wechat_user.nickname = user_info['nickname']
      @wechat_user.head_img_url = user_info['headimgurl']
    end
  end

  def like_agent
    aid = AgentExtention.find_by_agent_identifier(@msg_hash[:body]).user_id
    @wechat_user.update_attributes(agent_id: aid)

    media_id = REDIS.get("#{aid}_qr_media_id")
    unless media_id
      file = "./public/#{User.find(aid).qr_code[SERVER_HOST.length .. -1]}"
      media_id = WechatRequest.new.upload_image(file)['media_id']
      REDIS.setex("#{aid}_qr_media_id", 259200, media_id)
    end
    file = "./public/#{User.find(aid).qr_code[SERVER_HOST.length .. -1]}"

    @msg_hash[:body] = WechatRequest.new.upload_image(file)['media_id']
    image_response
  end

  def my_client
    if  @wechat_user.agent_id.to_i == @wechat_user.user_id
      @msg_hash[:items] = WechatUser.where(agent_id: @wechat_user.user_id).order('search_count DESC').limit(10).map do |user|
        search = if user.search
                   JSON.parse(user.search)
                 else
                   {}
                 end
        {title: "#{user.nickname}的需求: 城市: #{search['regionValue']} 价格: #{search['priceMin']} - #{search['priceMax']}",
         body: '',
         pic_url: user.head_img_url,
         url: "#{SERVER_HOST}/agent/set_search?uid=#{@wechat_user.user_id}&cid=#{user.id}"}
      end
      article_response
    else
      @msg_hash[:body] = "您目前并不是经纪人，请登录觅家网站完善信息"
      text_response
    end
  end

  def need_agent
    @msg_hash[:body] = '服务暂时没有开通'
    text_response
    #if agent = cached_input(:need_agent)
    #  @msg_hash[:body] = "您现在经纪人的需求是 #{agent}。您想根据此条件获取经纪人吗？请回复Y/y或者更新您想要的城市"
    #  set_redis(:wait_input, :agent_confirm)
    #  set_redis(:agent_confirm, agent)
    #  text_response
    #elsif search = cached_input(:home_search)
    #  @msg_hash[:body] = "您现在的搜索城市是 #{search}。您想根据此条件获取经纪人吗？请回复Y/y或者更新您想要的城市"
    #  set_redis(:wait_input, :agent_confirm)
    #  set_redis(:agent_confirm, search)
    #  text_response
    #else
    #  @msg_hash[:body] = '请输入您想要负责哪些城市的经纪人'
    #  set_redis(:wait_input, :agent_confirm)
    #  text_response
    #end
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
    @msg_hash[:items] = [{title: "请点击您的头像设置智能搜索条件",
                          body: '',
                          pic_url: @wechat_user.head_img_url,
                          url: "#{SERVER_HOST}/agent/set_search?uid=#{@wechat_user.agent_id}&cid=#{@wechat_user.id}"}]
    article_response
  end

  def my_favorite
    homes = User.find(@wechat_user.user_id).homes
    if homes.count > 0
      @msg_hash[:items] = home_search_items(homes)
      article_response
    else
      @msg_hash[:body] = '您还没有红心房源'
      text_response
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
        @msg_hash[:body] = "您所搜索的地区还没有房源更新, 请回复'u'更新搜索条件"
        text_response
      end

    else
      @msg_hash[:items] = [{title: "请点击您的头像设置智能搜索条件",
                           body: '',
                           pic_url: @wechat_user.head_img_url,
                           url: "#{SERVER_HOST}/agent/set_search?uid=#{@wechat_user.agent_id}&cid=#{@wechat_user.id}"}]
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

  def home_search_items(homes)
    ticket = TicketGenerator.encrypt_uid(@wechat_user.user_id)
    homes.map do |home|
      {title: "位于#{home.addr1} #{home.city}的 #{home.bed_num} 卧室 #{home.home_type}，售价：#{home.price}美金",
       body: 'nice home',
       pic_url: "#{SERVER_HOST}/#{home.images.first.try(:image_url) || 'default.jpeg'}",
       url: "#{CLIENT_HOST}/?ticket=#{ticket}#/home_detail/#{home.id}"}
    end
  end

  def set_redis(key, value)
    REDIS.setex("#{@msg_hash[:from_username]}:#{key}", 60, value.to_s)
  end

  def delete_redis(key)
    REDIS.del("#{@msg_hash[:from_username]}:#{key}")
  end

  def cached_input(type)
    REDIS.get("#{@msg_hash[:from_username]}:#{type}")
  end
end