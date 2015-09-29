class UserController < ApplicationController
  def index
    uid =  params[:uid].present? ? params[:uid] : session[:uid]
    result = uid.present? ? User.find(uid) : {}
    unless result
      render json: {}
      return
    end

    temp_json = JSON.parse result.to_json(include: [:saved_searches, :homes])   #TODO include image in homes
    temp_json.merge!(JSON.parse result.to_json(include: {:questions=> {include: {:answers => {include: :user}}}}))      #TODO what is this shit
    if result.agent_extention
      page_config = if result.agent_extention.page_config
                      JSON.parse(result.agent_extention.page_config)
                    else
                      {}
                    end
      search = if page_config['search']
                page_config['search'].map{|_, v| JSON.parse(v)}
               else
                 []
               end
      temp_json.merge!(agent_identifier: result.agent_extention.agent_identifier, published_page_config: {header: page_config['header'], search: search})   #TODO saved search
    end
    render json: temp_json.to_json  #TODO write to json method in model
  end

  def save_search
    uid = request.headers['HTTP_USER_ID']
    user = User.find(uid)
    p params
    user.create_search(params)
    p user.saved_searches
    render json: user.to_json(include: [:saved_searches])
  end

  def favorite_home
    uid = request.headers['HTTP_USER_ID']
    user = User.find(uid)
    user.add_favorite(params[:home_id])
    render json: user.to_json(include: [:homes])
  end

  def unfavorite_home
    uid = request.headers['HTTP_USER_ID']
    user = User.find(uid)
    user.remove_favorite(params[:home_id])
    render json: user.to_json(include: [:homes])
  end

  def submit_question
    uid = request.headers['HTTP_USER_ID']
    user = User.find(uid)
    user.create_question(params)
    render json: user.to_json(include: [:questions])    #TODO pagination
  end

end