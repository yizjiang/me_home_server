# encoding: utf-8

#require '../../lib/wechat/response_command'

class WechatController < ApplicationController

  before_filter :get_message_from_params
  METHOD_MAPPING = {'s' => :home_search,
                    'q' => :ask_question,
                    'a' => :need_agent,
                    'u' => :update_search
  }

  def auth
    render text: params['echostr']
  end

  def message
    response = if methond_sym = METHOD_MAPPING[@msg_hash[:body]]
                 send(methond_sym)
               elsif (service_type = cached_input(:wait_input))
                 delete_redis(:wait_input)
                 if(@msg_hash[:body]!= 'Y' && @msg_hash[:body] !='y')
                   set_redis(service_type, @msg_hash[:body])
                 end
                 send(service_type.to_sym)
               else
                 default_response
               end
    render xml: response
  end

  def test
    response = multi_reply({from_username: 1234, to_username: 5678, items: [{title: 'house1', body: 'nice home',
                                                                             pic_url: 'http://www.zillowstatic.com/static-homepage/7512d57/static-homepage/images/backgrounds/1500x675_white_home.jpg',
                                                                             url: 'www.google.com'},
                                                                            {title: 'house2', body: 'bay area',
                                                                             pic_url: 'http://cdn.freshome.com/wp-content/uploads/2013/08/selling-your-home-cedar-shingle-home.jpg',
                                                                             url: 'www.google.com'}]})
    render xml: response
  end

  private

  def get_message_from_params
    @msg_hash = {from_username: params['xml']['FromUserName'],
                 to_username: params['xml']['ToUserName'],
                 body: params['xml']['Content']}
  end

  def default_response
    @msg_hash[:body] = '对不起，以下消息 ' + @msg_hash[:body] + ' 无法自动回复，稍后会有人与您联系'
    text_response
  end

  def ask_question
    set_redis(:wait_input, :submit_question)
    @msg_hash[:body] = '请输入您想问问的问题'
    text_response
  end

  def submit_question
    p @msg_hash[:body]
    Question.create(open_id: @msg_hash[:from_username], text: @msg_hash[:body])
    @msg_hash[:body] = '问题已提交，您会在24小时内收到专业人士解答'
    text_response
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
    if value = REDIS.get("#{@msg_hash[:from_username]}:home_search")
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

  def text_response
    file_content = File.open(File.expand_path("./app/helpers/text_response.xml.erb"), "r").read
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
       pic_url: "http://81703363.ngrok.io/#{home.images.first.try(:image_url) || 'default.jpeg'}",
       url: home.link}
    end
  end

  def set_redis(key, value)
    REDIS.set("#{@msg_hash[:from_username]}:#{key}", value.to_s)
  end

  def delete_redis(key)
    REDIS.del("#{@msg_hash[:from_username]}:#{key}")
  end

  def cached_input(type)
    REDIS.get("#{@msg_hash[:from_username]}:#{type}")
  end
end