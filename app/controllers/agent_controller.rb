# encoding: utf-8

class AgentController < ApplicationController
  def index
    config = if page_config = AgentExtention.find_by_agent_identifier(params[:name]).page_config
               JSON.parse page_config
             else
               {}
             end

    search_config = config['search']

    if search_config
    searches = search_config.map{|_, v| Search.new(JSON.parse(v).with_indifferent_access.reject{|_, v| v.empty?})}

    result = Home.search(searches).map do |home|
      home.as_json
    end
    end
    render json: {header: config['header'], home_list: result }
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
    searches = search_config.map{|_, v| Search.new(JSON.parse(v).with_indifferent_access.reject{|_, v| v.empty?})}

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
    @customers = WechatUser.where(agent_id: params[:uid])
    render json: @customers, :include => [:wechat_trackings]
  end

  def set_search
    @customer = WechatUser.find(params[:cid])
    @agent_id = params[:uid]
    render 'agent/customer_search_form'
  end

  def save_customer_search
    @customer = WechatUser.find(params[:customer_id])
    if params[:regionValue].present?
      @customer.update_attributes(search: params.slice(:regionValue, :priceMin, :priceMax).to_json, last_search: nil)
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
end