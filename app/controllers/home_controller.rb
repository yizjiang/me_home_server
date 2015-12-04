class HomeController < ApplicationController
  def index
    if(params[:searches])
      search = Search.new(params[:searches][0].with_indifferent_access.reject{|_, v| v.empty?})
    else
      search = Search.new(params.with_indifferent_access.reject{|_, v| v.empty?})
    end
    result = Home.search(search).map do |home|
      home.as_json
    end
    render json: result
  end

  def show
    home = Home.find(params[:id])
    render json: home.as_json
  end

end

