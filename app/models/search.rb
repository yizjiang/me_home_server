# encoding: utf-8

class Search
  attr_accessor :region, :price_min, :price_max, :bed_num, :home_type, :indoor_size, :year_built

  def initialize(attributes)
    @region = attributes[:regionValue] || ''
    @price_min = if attributes[:priceMin].present?
                   attributes[:priceMin].to_f * 10000
                 else
                   0
                 end
    @price_max = if attributes[:priceMax].present?
                   attributes[:priceMax].to_f * 10000
                 else
                   1000000000
                end
    @bed_num = attributes[:bedNum] || 1
    @bed_num = @bed_num.to_i
    @indoor_size = attributes[:indoor_size] || 0
    @year_built = if attributes[:home_age]
                    Time.now.year - attributes[:home_age].to_i
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
    #@home_type = home_type_attr || Home.pluck(:home_type).uniq
    @home_type =  Home.pluck(:meejia_type).uniq
    if(attributes[:single_family] == 'false')
      @home_type -= ['Single Family Home']
    end
    if(attributes[:multi_family] == 'false')
      @home_type -= ['Duplex', 'Triplex', 'Fourplex']
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
      @home_type -= ['-', 'Mobile Home', 'Manufactured Home', nil]
    end
    p "xxx #{@home_type}"
  end
end
