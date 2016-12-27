class CommercialController < ApplicationController
  def index
    if(params[:addr])
      result = Commercial.search_by_address(params[:addr])
    else
      search = Search.new(params.with_indifferent_access.reject{|_, v| v.empty?})
      searches = search.region.split(',').map do |region|
        search = search.clone
        search.region = region.strip
        search
      end
    end

    render json: result
  end

  def show
    result = Commercial.find(params[:id])
    render json: result
  end
end
