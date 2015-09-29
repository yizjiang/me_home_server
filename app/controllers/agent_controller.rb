class AgentController < ApplicationController
  def index
    config = JSON.parse AgentExtention.find_by_agent_identifier(params[:name]).page_config
    search_config = config['search']

    if search_config
    searches = search_config.map{|_, v| Search.new(JSON.parse(v).with_indifferent_access.reject{|_, v| v.empty?})}

    result = Home.search(searches).to_json(include: [:schools, :images => {:only => :image_url}])
    end
    render json: {header: config['header'], home_list: JSON.parse(result || '[]') }
  end

  def save_page_config
    agent_extention = User.find(request.headers['HTTP_USER_ID']).agent_extention
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

    result = Home.search(searches).to_json(include: [:schools, :images => {:only => :image_url}])
    render json: {header: new_config['header'], home_list: JSON.parse(result) }
  end
end