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

  def show_all
    homes = Home.includes(:home_cn, :images).find(params[:ids].split(','))
    render json: homes.as_json(shorten: true)
  end

  def search_by_listing
    source_type = case params[:sourceType]
                    when 'mls'
                      ['MLSListings']
                    when 'the_mls'
                      ['TheMLS']
                    when 'crmls'
                      ['CRMLS']
                    when 'sf_mls'
                      ['San Francisco MLS']
                    when 'metro_list'
                      ['MetroList']
                    else
                      ['EBRD', 'SANDICOR', 'BAREIS', 'VCRDS', 'CRISNet']
                  end
    home = PublicRecord.where('source in (?) and property_id like ?', source_type, params[:sourceId].strip).first.try(:home)
    if home
      render json: home.as_json(shorten: true)
    else
      render json: {}
    end
  end
end

