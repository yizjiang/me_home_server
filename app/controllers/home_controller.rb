class HomeController < ApplicationController
  def index
    search = Search.new(params.with_indifferent_access.reject{|_, v| v.empty?})
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

