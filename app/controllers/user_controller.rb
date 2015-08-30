class UserController < ApplicationController
  def index
    uid =  params[:uid].present? ? params[:uid] : session[:uid]
    result = uid.present? ? User.find(uid) : {}
    render json: result.to_json(include: [:saved_searches, :questions])  #TODO write to json method in model
  end

  def save_search
    uid = request.headers['HTTP_USER_ID']
    user = User.find(uid)
    user.create_search(params)
    render json: user.to_json(include: [:saved_searches])
  end

  def favorite_home
    uid = request.headers['HTTP_USER_ID']
    user = User.find(uid)
    user.add_favorite(params[:home_id])
    render json: user.to_json(include: [:homes])
  end


  def submit_question
    uid = request.headers['HTTP_USER_ID']
    user = User.find(uid)
    user.create_question(params)
    render json: user.to_json(include: [:questions])    #TODO pagination
  end

end