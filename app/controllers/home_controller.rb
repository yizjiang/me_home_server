class HomeController < ApplicationController
  def index
    if(params[:searches])
      searches = Search.new(params[:searches][0].with_indifferent_access.reject{|_, v| v.empty?})
    else
      search = Search.new(params.with_indifferent_access.reject{|_, v| v.empty?})
      searches = search.region.split(',').map do |region|
        search = search.clone
        search.region = region
        search
      end
    end
    result = Home.search(searches).map do |home|
      home.as_json
    end
    render json: result
  end

  def show
    home = Home.find(params[:id])
    render json: home.as_json
  end

end

