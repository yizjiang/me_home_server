class HomeController < ApplicationController
  def index
    search = Search.new(params.with_indifferent_access.reject{|_, v| v.empty?})
    render json: Home.search(search).to_json(include: [:schools, :images => {:only => :image_url}])
  end
end