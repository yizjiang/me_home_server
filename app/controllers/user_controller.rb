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

      if WechatUser.where(user_id: uid).empty?
        expect_url = "public/agents/#{uid}0.png"
        unless File.exist?(expect_url)
          WechatRequest.new.generate_qr_code("#{uid}0")
        end

        qr_image = {img_url: "agents/#{uid}0.png",
                    is_followed: false}
      else
        expect_url = "public/agents/#{uid}1.png"
        unless File.exist?(expect_url)
          WechatRequest.new.generate_qr_code("#{uid}1")
        end
        qr_image = {img_url: "agents/#{uid}1.png",
                    is_followed: true}
      end

      temp_json.merge!(agent_identifier: result.agent_extention.agent_identifier,
                       published_page_config: {header: page_config['header'],
                                               search: search},
                       qr_image: qr_image)   #TODO saved search
    end
    render json: temp_json.to_json  #TODO write to json method in model
  end

  def save_search
    uid = request.headers['HTTP_UID']
    user = User.find(uid)
    home_type = ['Single Family Home', 'Multi-Family Home', 'Condo/Townhome/Row Home/Co-Op']
    if(params[:single_family] == 'false')
      home_type -= ['Single Family Home']
    end
    if(params[:multi_family] == 'false')
      home_type -= ['Multi-Family Home']
    end
    if(params[:condo] == 'false')
      home_type -= ['Condo/Townhome/Row Home/Co-Op']
    end
    params[:home_type] = home_type
    user.create_search(params)
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