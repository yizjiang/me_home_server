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
    end

    header_config = config['header']
    unless header_config
      header_config = {name: agent_extention.user.try(:wechat_user).try(:nickname)}
    end

    render json: {header: header_config, home_list: home_list,
                  qr_image: agent_extention.user.qr_code,
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
      flash[:notice] = "城市不能为空"
      render 'agent/customer_search_form'
    end

  end

  def active_agents
    agents = []
    want_num_agent = 4
    agent_ids = AgentExtention.pluck(:user_id)

    if uid = request.headers['HTTP_UID']
      user = User.find(uid)
      if agent_id = user.wechat_user.agent_id
        want_num_agent = 3
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