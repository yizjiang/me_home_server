class Search
  attr_accessor :region, :price_min, :price_max, :bed_num, :home_type

  def initialize(attributes)
    @region = attributes[:regionValue] || ''
    @price_min = if attributes[:priceMin].present?
                   attributes[:priceMin]
                 else
                   0
                 end
    @price_max = if attributes[:priceMax].present?
                   attributes[:priceMax]
                 else
                   1000000000
                end
    @bed_num = attributes[:bedNum] || 0
    @home_type = attributes[:home_type] || ['Single Family Home', 'Multi-Family Home', 'Condo/Townhome/Row Home/Co-Op']
    if(attributes[:single_family] == 'false')
      @home_type -= ['Single Family Home']
    end
    if(attributes[:multi_family] == 'false')
      @home_type -= ['Multi-Family Home']
    end
    if(attributes[:condo] == 'false')
      @home_type -= ['Condo/Townhome/Row Home/Co-Op']
    end
  end
end