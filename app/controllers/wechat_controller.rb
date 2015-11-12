# encoding: utf-8

#require '../../lib/wechat/response_command'

class WechatController < ApplicationController
  before_filter :get_message_from_params, :if => lambda {request.post?}

  METHOD_MAPPING = {'s' => :home_search,
                    'q' => :ask_question,
                    'a' => :need_agent,
                    'u' => :update_search,
                    'cq' => :customer_questions,
                    'pc' => :agent_request,
                    'agent_follow' => :followed_by_agent,
                    'my_client' => :my_client,
                    'subscribe' => :subscribe

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

  def get_message_from_params
    p "xxx #{params}"
    body = case params['xml']['MsgType']
             when 'text'
               params['xml']['Content']
             when 'event'
               if  params['xml']['Event'] == 'SCAN'
                 @agent_id = params['xml']['EventKey']
                 'agent_follow'
               elsif params['xml']['Event'] == 'subscribe'
                 'subscribe'
               else
                 params['xml']['EventKey']
               end
             else
               ''
           end
    @msg_hash = {from_username: params['xml']['FromUserName'],
                 to_username: params['xml']['ToUserName'],
                 body: body}
  end

  def default_response
    @msg_hash[:body] = '对不起，以下消息 ' + @msg_hash[:body] + ' 无法自动回复，稍后会有人与您联系'
    text_response
  end

  def subscribe
    @msg_hash[:body] = '觅家公众号竭诚为您服务'
    text_response
  end

  def ask_question
    set_redis(:wait_input, :submit_question)
    @msg_hash[:body] = '请输入您想问问的问题'
    text_response
  end

  def submit_question
    Question.create(open_id: @msg_hash[:from_username], text: @msg_hash[:body])
    @msg_hash[:body] = '问题已提交，您会在24小时内收到专业人士解答'
    text_response
  end

  def customer_questions
    question = Question.last
    set_redis(:wait_input, :answer_question)
    set_redis(:answer_question, question.id)
    username = if open_id = question.open_id
                 WechatUser.find_by_open_id(open_id).nickname
               else
                 'xxx'
               end
    @msg_hash[:body] = "#{username}提问: #{question.text}"
    text_response
  end

  def answer_question
    question = Question.find(cached_input(:answer_question).to_i)
    delete_redis(:answer_question)
    question.create_answer(@msg_hash[:body], 5)  #agent and user mapping.
    @msg_hash[:body] = "回复已提交"
    text_response
  end

  def followed_by_agent
    user_info = fetch_user_info(@msg_hash[:from_username])
    p user_info
    user = WechatUser.find_or_initialize_by_open_id(@msg_hash[:from_username]) do |user|
      user.agent_id = @agent_id
      user.nickname = user_info['nickname']
      user.head_img_url = user_info['headimgurl']
      user.save
    end
    p user
    @msg_hash[:body] = "经纪人#{User.find(@agent_id).agent_extention.agent_identifier}非常荣幸能为您服务"
    text_response
  end

  def fetch_user_info(open_id)
    params = {grant_type: 'client_credential',
              appid: WECHAT_CLIENTID,
              secret: WECHAT_CLIENTSECRET}
    response = Typhoeus.get("https://api.weixin.qq.com/cgi-bin/token", params: params)
    access_token = JSON.parse(response.body)['access_token']

    url = "https://api.weixin.qq.com/cgi-bin/user/info?access_token=#{access_token}&openid=#{open_id}&lang=zh_CN"
    response = Typhoeus.get(url)
    JSON.parse(response.body)
  end

  def like_agent
    wechat_user = WechatUser.find_by_open_id(@msg_hash[:from_username])
    wechat_user.update_attributes(agent_id: 5) #TODO agent mapping
    @msg_hash[:body] = 'YlM5aa_RKJ9gTrXiOMTyIf8ulaX-UDde-peoi9Wp9xEVxeMlJdEoqnPADgUH_e1K'
    image_response
  end

  def my_client
    @msg_hash[:items]  = WechatUser.where(agent_id: 5).map do |user|
      search = if user.search
                 JSON.parse(user.search)
               else
                 {}
               end
      {title: user.nickname,
       body: "城市: #{search['city']}, 价格区间: #{search['price_range']}",
       pic_url: user.head_img_url,
       url: "http://7997baf7.ngrok.io/agent/set_search?uid=5&cid=#{user.id}"}
    end
    p @msg_hash[:items]
    article_response
  end

  def need_agent
    if agent = cached_input(:need_agent)
      @msg_hash[:body] = "您现在经纪人的需求是 #{agent}。您想根据此条件获取经纪人吗？请回复Y/y或者更新您想要的城市（用逗号分隔）"
      set_redis(:wait_input, :agent_confirm)
      set_redis(:agent_confirm, agent)
      text_response
    elsif search = cached_input(:home_search)
      @msg_hash[:body] = "您现在的搜索城市是 #{search}。您想根据此条件获取经纪人吗？请回复Y/y或者更新您想要的城市（用逗号分隔）"
      set_redis(:wait_input, :agent_confirm)
      set_redis(:agent_confirm, search)
      text_response
    else
      @msg_hash[:body] = '请输入您想要负责哪些城市的经纪人（城市用逗号分隔）'
      set_redis(:wait_input, :agent_confirm)
      text_response
    end
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
    @msg_hash[:body] = "您现在的搜索地区是 #{ cached_input(:home_search)}, 请输入新的搜索条件"
    set_redis(:wait_input, :home_search)
    text_response
  end

  def home_search
    @user_input = if search = WechatUser.find_by_open_id(@msg_hash[:from_username]).search
                    JSON.parse(search)['city']
                  else
                    nil
                  end
    if value = @user_input
      searches = value.split(',').map do |value|
        Search.new(regionValue: value)
      end
      homes = Home.search(searches, 10/searches.count) # fair divide?

      @msg_hash[:items] = home_search_items(homes)
      article_response
    else
      set_redis(:wait_input, :home_search)
      @msg_hash[:body] = '对不起, 您还未设置快速搜索，请输入您所需要房源的地区，用逗号隔开'
      text_response
    end
  end

  def agent_request
    @msg_hash[:body] = "User #{AgentRequest.last.open_id} request agent help in #{AgentRequest.last.region} area"
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
    homes.map do |home|
      {title: "#{home.bed_num} Beds #{home.home_type} at #{home.addr1} #{home.city}",
       body: 'nice home',
       pic_url: "http://cb549de3.ngrok.io/#{home.images.first.try(:image_url) || 'default.jpeg'}",
       url: "#{CLIENT_HOST}/#/home_detail/#{home.id}"}
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