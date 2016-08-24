# encoding: utf-8

class AgentController < ApplicationController
  def show
    agent_extention = User.find(params[:id]).agent_extention
    render json: agent_info(agent_extention)
  end

  def edit
    agent = User.find(params[:id])
  end

  def meejia_image
    uid = params[:id]
    if WechatUser.where(user_id: uid).empty?
      expect_url = "public/agents/#{uid}0.png"
      unless File.exist?(expect_url)
        WechatRequest.new.generate_qr_code("#{uid}0")
      end

      qr_image = {img_url: "#{SERVER_HOST}/agents/#{uid}0.png",
                  meejia_url: "#{SERVER_HOST}/shared_qr/login.png",
                  is_followed: false}
    else
      expect_url = "public/agents/#{uid}1.png"
      unless File.exist?(expect_url)
        WechatRequest.new.generate_qr_code("#{uid}1")
      end
      qr_image = {img_url: "#{SERVER_HOST}/agents/#{uid}1.png",
                  is_followed: true}
    end
    render json: qr_image
  end

  def generate_home_qr_code
    home_id = params[:home_id]
    agent_id = params[:id]

    scene_str = "h#{home_id}a#{agent_id}"
    expect_file = "public/agents/#{scene_str}.png"
    if File.exist?(expect_file)
      qr_img = "/agents/#{scene_str}.png"
    else
      qr_img = WechatRequest.new.generate_home_code(scene_str)
    end
    Home.find(home_id).update_attributes(listing_agent: agent_id)
    render json: {qrImage: qr_img}
  end

  def index
    agent_extention = AgentExtention.find_by_agent_identifier(params[:name])
    if params[:uid] && wuser = WechatUser.find_by_user_id(params[:uid])
      WechatTracking.create(tracking_type: "agent viewed", wechat_user_id: wuser.id, item: agent_extention.user_id)
    end
    render json: agent_info(agent_extention)
  end

  def home_list
    home_list = []
    agent_extention = User.find(params[:id]).agent_extention
    if search_config = agent_extention.page_config
      search = JSON.parse(search_config)
      searches = search['regionValue'].split(',').map do |s|
        criteria = search.clone
        criteria['regionValue'] = s
        Search.new(criteria.with_indifferent_access.reject{|_, v| v.to_s.empty?})       #home num is a number
      end

      home_list = Home.search(searches).sample(8).map do |home|
        home.as_json(shorten: true)
      end
    else
      home_list = []
      HOT_AREAS.sample(4).each do |area|
        home_list += Home.search(Search.new(regionValue: area), 2).map do |home|
          home.as_json(shorten: true)
        end
      end
    end
    render json: home_list
  end

  def save_page_config
    agent_extention = User.find(request.headers['HTTP_UID']).agent_extention
    result = []

    if params[:header]
      agent_extention.update_attributes(cn_name: params[:header][:name],
                                        phone: params[:header][:phone],
                                        license_id: params[:header][:license],
                                        mail: params[:header][:email],
                                        description: params[:header][:description])
    end

    if params[:search]
      agent_extention.update_attributes(page_config: params[:search].to_json)  #TODO use search.search_query to populate
    end

    #if search_config = agent_extention.page_config
    #  search = JSON.parse(search_config)
    #  searches = search['regionValue'].split(',').map do |s|
    #    criteria = search.clone
    #    criteria['regionValue'] = s
    #    Search.new(criteria.with_indifferent_access.reject{|_, v| v.to_s.empty?})       #home num is a number
    #  end
    #end
    #
    #result = Home.search(searches).map do |home|
    #  home.as_json
    #end
    render json: agent_info(agent_extention)#.merge(home: result)
  end

  def agent_info(agent_extention)
    {
      agent_id: agent_extention.user.id,
      agent_identifier: agent_extention.agent_identifier,
      license_year: agent_extention.license_issue,
      license_id: agent_extention.license_id,
      page_config: agent_extention.page_config,
                  qr_code: agent_extention.user.qr_code,
                  description: agent_extention.description,
                  cn_name: agent_extention.cn_name || agent_extention.user.try(:wechat_user).try(:nickname),
                  phone: agent_extention.phone,
                  mail: agent_extention.mail,
                  wechat: agent_extention.wechat,
                  head_image: agent_extention.user.wechat_user.try(:head_img_url) }

  end
  def upload_qrcode
    uid = request.headers['HTTP_UID']
    File.open("./public/agents/#{uid}_qrcode.png", 'wb') do |outfile|
      outfile.write(params[:file].tempfile.read)
    end
    qr_code = "#{SERVER_HOST}/agents/#{uid}_qrcode.png"
    user = User.find(uid)
    user.update_attributes(qr_code: qr_code)
    render json: {url: user.qr_code}
  end

  def all_customer
    @customers = WechatUser.where(agent_id: params[:uid]).includes(:wechat_trackings, :user).map do |wuser|
                    favorites = wuser.user.homes.map do |home|
                      home.as_json(shorten: true)
                    end
                    customer_hash = wuser.as_json.merge(favorites: favorites)
                    home_ids = wuser.wechat_trackings.pluck(:item).map{|id| id.to_i}
                    interest_homes = Home.select([:id, :addr1, :city]).where( "id in (?)", home_ids).map do |home|
                      home.as_json(shorten: true)
                    end
                    customer_hash.merge(interest: interest_homes)
    end
    render json: @customers
  end

  def all_request
    requests = AgentRequest.where(to_user: params[:uid], status: 'open')
    home_ids = requests.pluck(:request_context_id)
    requests = home_ids.map do |homeid|
      {home_id: homeid, requests: requests.select{|r| r.request_context_id == homeid}.map(&:as_json)}
    end
    render json: requests
  end

  def set_search
    @customer = WechatUser.find(params[:cid])
    @agent_id = params[:uid]
    render 'agent/customer_search_form'
  end

  def save_customer_search
    @customer = WechatUser.find(params[:customer_id])
    user = User.find(@customer.user_id)
    search = Search.new(params.with_indifferent_access.reject{|_, v| v.to_s.empty?})
    user.create_search(search.search_query)
    if params[:regionValue].present?
      @customer.update_attributes(search: search.search_query.to_json, last_search: nil)
      if params[:api]
        render json: {}
      else
        flash[:notice] = "设置已保存"
        render 'agent/customer_search_form'
      end
    else
      if params[:api]
        render :status =>500, json:{}
      else
        flash[:notice] = "城市不能为空"
        render 'agent/customer_search_form'
      end
    end

  end

  def contact_request
    if params[:toUser]
      params[:toUser].values.each do |aid|
        body = "#{User.find(request.headers['HTTP_UID']).wechat_user.try(:nickname) || '路人甲'} 想知道更多%{detail}的信息"
        AgentRequest.where(from_user: request.headers['HTTP_UID'], request_type: 'home', request_context_id: params[:home_id], to_user: aid, status: 'open', body: body).first_or_create
      end
    else
      AgentRequest.where(from_user: request.headers['HTTP_UID'], request_type: 'home', request_context_id: params[:home_id], status: 'open').first_or_create
    end

    render json:[]
  end

  def request_response
    uid = request.headers['HTTP_UID']
    requestIds = params[:requests].values
    requestIds.each do |rid|
      request= AgentRequest.find(rid.to_i)
      open_id = WechatUser.find_by_user_id(request.from_user).try(:open_id)
      request.update_attributes(status: 'closed', response: params[:msg], to_user: uid)
      ReplyWorker.perform_async(open_id, 'request_response', request.id) if open_id
    end
    render json:[]
  end

  def active_agents
    agents = []
    want_num_agent = 3
    agent_ids = AgentExtention.where(status: 'Active').where('user_id is not NULL').pluck(:user_id)

    if uid = request.headers['HTTP_UID']
      user = User.find(uid)
      if agent_id = user.wechat_user.agent_id
        want_num_agent -= 1
        agents << User.find(agent_id.to_i)
        agent_ids -= [agent_id.to_i]
      end
    end

    agents = agents + User.where('qr_code is not NULL and id in (?)', agent_ids)
    agents = agents.sample(want_num_agent)
    render json: agents.map{|a| agent_info(a.agent_extention)}
  end

  private
  def get_searches

  end
end
