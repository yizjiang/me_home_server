# encoding: utf-8
HOME_TYPE = Home.pluck(:meejia_type).uniq
class Search
  attr_accessor :region, :price_min, :price_max, :bed_num, :home_type, :indoor_size, :year_built, :search_query

  def initialize(attributes)
    @region = attributes[:regionValue] || ''
    @search_query = {regionValue: @region}

    @price_min = if attributes[:priceMin].present?
                   @search_query[:priceMin] = attributes[:priceMin].to_f
                   attributes[:priceMin].to_f * 10000
                 else
                   0
                 end
    @price_max = if attributes[:priceMax].present?
                   @search_query[:priceMax] = attributes[:priceMax].to_f
                   attributes[:priceMax].to_f * 10000
                 else
                   1000000000
                end
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

    if(attributes[:single_family] == 'false')
      @home_type -= ['Single Family Home']
    end
    if(attributes[:multi_family] == 'false')
      @home_type -= ['Multi Family Home', 'Duplex', 'Triplex', 'Fourplex']
    end
    if(attributes[:condo] == 'false')
      @home_type -= ['Apartment', 'Condominium']
    end
    if(attributes[:townhouse] == 'false')
      @home_type -= ['Townhouse']
    end
    if(attributes[:business] == 'false')
      @home_type -= ['Mixed Use']
    end
    if(attributes[:land] == 'false')
      @home_type -= ['Residential Land', 'Residential Lot', 'Land']
    end
    if(attributes[:farm] == 'false')
      @home_type -= ['Farms', 'Ranches']
    end
    if(attributes[:other] == 'false')
      @home_type -= ['-', 'Mobile Home', 'Manufactured Home', 'Other', nil]
    end
    @search_query[:home_type] = @home_type
  end

end
