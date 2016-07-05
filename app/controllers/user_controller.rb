class UserController < ApplicationController

  def index
    temp_json = get_user_json(params)
    render json: temp_json.to_json  #TODO write to json method in model
  end

  def wechat_search
    if search = WechatUser.find(params[:id]).search
      search = JSON.parse search
    else
      search = {}
    end
    render json: search
  end

  def send_home_card
    User.find(request.headers['HTTP_UID']).wechat_user.send_home_on_wechat(params[:home_id])
    render json: {}
  end

  def get_user_json(params)
    uid =  params[:uid].present? ? params[:uid] : session[:uid]
    result = uid.present? ? User.find(uid) : {}
    unless result
      render json: {}
      return
    end

    temp_json = result.as_json
    temp_json.merge!(JSON.parse result.to_json(include: {:questions=> {include: {:answers => {include: :user}}}}))      #TODO what is this shit

    if result.agent_extention
      temp_json.merge!(agent_identifier: result.agent_extention.agent_identifier)   #TODO saved search
    end
    return temp_json
  end

  def save_search
    uid = request.headers['HTTP_UID']
    user = User.find(uid)
    search = Search.new(params.with_indifferent_access.reject{|_, v| v.to_s.empty?})
    user.create_search(search.search_query)
    render json: user.to_json(include: [:saved_searches])
  end

  def remove_search
    SavedSearch.find(params[:id].to_i).destroy
    render json: []
  end

  def favorite_home
    uid = request.headers['HTTP_UID']
    user = User.find(uid)
    user.add_favorite(params[:home_id])
    render json: user.to_json(include: [:homes])
  end

  def unfavorite_home
    uid = request.headers['HTTP_UID']
    user = User.find(uid)
    user.remove_favorite(params[:home_id])
    render json: user.to_json(include: [:homes])
  end

  def submit_question
    uid = request.headers['HTTP_UID']
    user = User.find(uid)
    user.create_question(params)
    render json: user.to_json(include: [:questions])    #TODO pagination
  end

  def metric_tracking
    uid = request.headers['HTTP_UID']
    user = User.find(uid)
    WechatTracking.where(wechat_user_id: user.wechat_user.try(:id), tracking_type: 'home viewed', item: params[:home_id]).first_or_create
    render json: []
  end
end