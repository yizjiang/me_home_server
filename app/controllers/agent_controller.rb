# encoding: utf-8

class AgentController < ApplicationController
  def index
    home_list = []
    agent_extention = AgentExtention.find_by_agent_identifier(params[:name])
    config = if page_config =agent_extention.page_config
               JSON.parse page_config
             else
               {}
             end

    search_config = config['search']

    if search_config
      search = JSON.parse search_config['0']
      searches = search['regionValue'].split(',').map do |s|
        criteria = search.clone
        criteria['regionValue'] = s
        Search.new(criteria.with_indifferent_access.reject{|_, v| v.to_s.empty?})
      end

      home_list = Home.search(searches).map do |home|
        home.as_json
      end
    else
      home_list = []
      HOT_AREAS.sample(5).each do |area|
        home_list += Home.search(Search.new(regionValue: area), 5).map do |home|
          home.as_json
        end
      end
    end

    header_config = config['header']
    unless header_config
      header_config = {name: agent_extention.user.try(:wechat_user).try(:nickname)}
    end

    render json: {header: header_config, home_list: home_list,
                  qr_image: agent_extention.user.qr_code,
                  description: agent_extention.description,
                  cn_name: agent_extention.cn_name,
                  phone: agent_extention.phone,
                  mail: agent_extention.mail,
                  wechat: agent_extention.wechat,
                  head_image: agent_extention.user.wechat_user.try(:head_img_url) }
  end

  def save_page_config
    agent_extention = User.find(request.headers['HTTP_UID']).agent_extention
    new_config = if agent_extention.page_config
                   JSON.parse(agent_extention.page_config)
                 else
                   {}
                 end
    if params[:header]
      new_config['header'] = params[:header]
    elsif params[:search]
      new_config['search'] = params[:search]
    end
    agent_extention.update_attributes(page_config: new_config.to_json)

    search_config = JSON.parse(agent_extention.page_config)['search']

    if search_config
      search = JSON.parse search_config['0']
      searches = search['regionValue'].split(',').map do |s|
        criteria = search.clone
        criteria['regionValue'] = s
        Search.new(criteria.with_indifferent_access.reject{|_, v| v.to_s.empty?})       #home num is a number
      end
    end

    result = Home.search(searches).map do |home|
      home.as_json
    end
    render json: {header: new_config['header'], home_list: result }
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
                      home.as_json(addr_only: true)
                    end
                    customer_hash = wuser.as_json.merge(favorites: favorites)
                    home_ids = wuser.wechat_trackings.pluck(:item).map{|id| id.to_i}
                    interest_homes = Home.select([:id, :addr1, :city]).where( "id in (?)", home_ids).map do |home|
                      home.as_json(addr_only: true)
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
      AgentRequest.where(from_user: request.headers['HTTP_UID'], request_type: 'home', request_context_id: params[:home_id]).first_or_create
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
    agent_ids = AgentExtention.where('user_id is not NULL').pluck(:user_id)

    if uid = request.headers['HTTP_UID']
      user = User.find(uid)
      if agent_id = user.wechat_user.agent_id
        want_num_agent -= 1
        p agent_id
        agents << User.find(agent_id.to_i).as_json(include_details: false)
        agent_ids -= [agent_id.to_i]
      end
    end
    agent_ids = agent_ids.sample(want_num_agent)

    agents = agents + User.find(agent_ids).map{|agent| agent.as_json(include_details: false)}
    render json: agents
  end

  private
  def get_searches

  end
end
