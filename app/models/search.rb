class Search
  attr_accessor :region, :price_min, :price_max

  def initialize(attributes)
    @region = attributes[:regionValue] || ''
    @price_min = attributes[:priceMin] || 0
    @price_max = attributes[:priceMax] || 1000000000
  end
end