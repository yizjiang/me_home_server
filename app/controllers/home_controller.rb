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

  def search_by_price
    indoor_size = params[:indoor_size].to_i / 0.092
    price = params[:price].to_i / 6.67 * params[:indoor_size].to_i  + params[:cash].to_i / 6.67
    query = 'city in (?) and price < ? and status = ? and indoor_size > ? and meejia_type in (?)'

    city = [['Redwood City', 'San Mateo', 'San Bruno', 'Millbrae', 'Burlingame'], ['Sunnyvale', 'San Jose'], ['Fremont', 'Union City']]
    region = ['peninsula', 'silicon_vally', 'east_bay']
    response = {}
    city.each_with_index do |city, index|
      homes = Home.where(query ,city, price, 'Active', indoor_size,
                          ['Single Family Home', 'Townhouse', 'Condominium', 'Apartment']).includes(:home_cn, :images).order(:price).limit(20).sample(8)
      response.merge!(Hash[region[index], homes.as_json(shorten: true, all_images: true)])
    end
    render json: response
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

