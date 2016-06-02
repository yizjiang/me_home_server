# encoding: utf-8
HOME_TYPE = Home.pluck(:meejia_type).uniq
class Search
  attr_accessor :region, :price_min, :price_max, :bed_num, :home_type, :indoor_size, :year_built, :client_home_type, :search_query

  def default_attributes
    cities = Home.select('DISTINCT city').sample(2).map(&:city)
    {
     regionValue: cities.join(','),
     priceMin: '',
     priceMax: '',
     bedNum: 2,
     single_family: true,
     condo: true,
     townhouse: true,
     multi_family: true,
     business: true,
     land: false,
     farm: false,
     other: false}

  end

  def normal_home

  end

  def initialize(attributes = nil)
    attributes ||= default_attributes
    @region = attributes[:regionValue] || ''
    @search_query = {regionValue: @region}

    @price_min = if attributes[:priceMin].present?
                   attributes[:priceMin].to_f * 10000
                 else
                   0
                 end
    @search_query[:priceMin] = @price_min/10000
    @price_max = if attributes[:priceMax].present?
                   attributes[:priceMax].to_f * 10000
                 else
                   1000000000
                 end
    @search_query[:priceMax] = @price_max/10000
    @bed_num = attributes[:bedNum] || 1
    @bed_num = @bed_num.to_i
    @search_query[:bedNum] = @bed_num

    @indoor_size = if attributes[:indoor_size].present?
                     @search_query[:indoor_size] = attributes[:indoor_size]
                     attributes[:indoor_size]
                   else
                     0
                   end

    @year_built = if attributes[:home_age]
                    age = Time.now.year - attributes[:home_age].to_i
                    @search_query[:home_age] = attributes[:home_age].to_i
                    age
                  else
                    1900
                  end

    home_type_attr = if attributes[:home_type].is_a? Array
                       attributes[:home_type]
                     elsif attributes[:home_type].is_a? Hash
                       attributes[:home_type].values
                     else
                       nil
                     end
    @home_type = home_type_attr || HOME_TYPE
    @client_home_type = %w(single_family multi_family condo townhouse business land farm other)

    if(attributes[:single_family] == 'false')
      @home_type -= ['Single Family Home']
      @client_home_type -= ['single_family']
    end
    if(attributes[:multi_family] == 'false')
      @home_type -= ['Multi Family Home', 'Duplex', 'Triplex', 'Fourplex']
      @client_home_type -= ['multi_family']
    end
    if(attributes[:condo] == 'false')
      @home_type -= ['Apartment', 'Condominium']
      @client_home_type -= ['condo']
    end
    if(attributes[:townhouse] == 'false')
      @home_type -= ['Townhouse']
      @client_home_type -= ['townhouse']
    end
    if(attributes[:business] == 'false')
      @home_type -= ['Mixed Use']
      @client_home_type -= ['business']
    end
    if(attributes[:land] == 'false')
      @home_type -= ['Residential Land', 'Residential Lot', 'Land']
      @client_home_type -= ['land']
    end
    if(attributes[:farm] == 'false')
      @home_type -= ['Farms', 'Ranches']
      @client_home_type -= ['farm']
    end
    if(attributes[:other] == 'false')
      @home_type -= ['-', 'Mobile Home', 'Manufactured Home', 'Other', nil]
      @client_home_type -= ['other']
    end
    @search_query[:home_type] = @home_type
    @search_query[:client_home_type] = @client_home_type
  end

end
