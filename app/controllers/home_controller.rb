class HomeController < ApplicationController
  def index
    search = Search.new(params.with_indifferent_access.reject{|_, v| v.empty?})
    #TODO
    #temp_json = JSON.parse(Home.search(search).to_json(include: [:images => {:only => :image_url}]))
    #temp_json.each do |home|
    #  home[:assigned_school] = Home.find(home['id'].to_i).schools.assigned
    #  home[:public_schools] = Home.find(home['id'].to_i).schools.other_public
    #  home[:private_schools] = Home.find(home['id'].to_i).schools.private
    #end
    #render json: temp_json.to_json
    result = Home.search(search).map do |home|
      home.as_json
    end
    render json: result
  end

  def show
    if params[:wid].present?
      WechatTracking.where(wechat_user_id: params[:wid], tracking_type: 'home interest', item: params[:id]).first_or_create
    end

    home = Home.find(params[:id])
    render json: home.as_json
  end

end

