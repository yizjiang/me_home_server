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

  def all_city
    result = ALL_CITY[params[:area]].clone
    result = result.push(*(Home.pluck(:zipcode).uniq.map(&:to_s)))
    render json: result
  end

  def bay_area_cities
    result = ALL_CITY[params[:area]]
    render json: result
  end
end