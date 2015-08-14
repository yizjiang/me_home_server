class RegionController < ApplicationController
  def index
    if params[:region].nil?
      regions = ['New York', 'Bay Area']
    elsif params[:region] == 'Bay Area'
      regions = Home.pluck(:city).uniq
    else
      regions = []
    end
   render json: regions
  end
end