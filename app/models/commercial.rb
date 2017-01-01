class Commercial < ActiveRecord::Base
  attr_accessible :addr1, :agent_extention_id, :broker_company_id, :cap_rate, :category, :city, :costar_link, :county, :created_at, :geo_point, :land_size, :last_updated, :market, :name, :num_of_properties, :on_market, :price, :price_sf, :property_type, :rating, :rating, :sale_type, :size, :source_id, :state, :status, :stories, :submarket, :updated_at, :year_b_r, :zipcode

  extend SearchByAddress
  has_many :properties, foreign_key: :sale_property_id
  has_many :commercial_images

  alias images commercial_images

  def self.importer(row)

    #status = row[3].nil? ? nil : row[3].lstrip.rstrip
    addr1 = row[17].nil? ? nil : row[17].lstrip.rstrip
    city = row[18].nil? ? nil : row[18].lstrip.rstrip
    county = row[19].nil? ? nil : row[19].lstrip.rstrip
    zipcode  = row[20].nil? ? nil : row[20].lstrip.rstrip
    state = row[21].nil? ? nil : row[21].lstrip.rstrip

    uniq_condition =
      {
      addr1: addr1,
      city: city,
      state: state,
      county: county,
      zipcode: zipcode,
      source_id: row[0].lstrip.rstrip
    }

    
   # a_commercial = Commercial.where(uniq_condition).first_or_create
    a_commercial = Commercial.where(uniq_condition).first
    print "uniq_condition: ", uniq_condition, "\n" unless a_commercial.nil?
    a_commercial = Commercial.new(uniq_condition) if a_commercial.nil? 

    if (!a_commercial.nil?)
      #print "update", row[0], "\n"
      a_commercial.source_id = row[0].nil? ? a_commercial.source_id: row[0].lstrip.rstrip if a_commercial.source_id.nil?
      a_commercial.costar_link = row[1].nil? ?  a_commercial.costar_link: row[1].lstrip.rstrip if a_commercial.costar_link.nil?
      a_commercial.sale_type = row[2].nil? ? a_commercial.sale_type : row[2].lstrip.rstrip 
      a_commercial.status = row[3].nil? ? a_commercial.status: row[3].lstrip.rstrip
      if  (!row[4].nil? && !row[4].eql?("null"))
        a_commercial.name = row[4].nil? ? a_commercial.name : row[4].lstrip.rstrip 
      end
      a_commercial.size  = row[5].nil? ? a_commercial.size : row[5].delete(',')
      a_commercial.price  = row[6].nil? ? a_commercial.price : row[6].delete(',')
      a_commercial.price_sf  = row[7].nil? ? a_commercial.price_sf : row[7].delete(',')
      a_commercial.cap_rate  = row[8].nil? ? a_commercial.cap_rate : row[8]
      a_commercial.on_market  = row[9].nil? ? a_commercial.on_market : row[9]
      a_commercial.last_updated  = row[10].nil? ? a_commercial.last_updated : row[10].lstrip.rstrip
      a_commercial.num_of_properties  = row[11].nil? ? a_commercial.num_of_properties : row[11].lstrip.rstrip 
      a_commercial.land_size  = row[12].nil? ? a_commercial.land_size : row[12].lstrip.rstrip 
      a_commercial.property_type  = row[15].nil? ? a_commercial.property_type : row[15].lstrip.rstrip 
      
      if (!a_commercial.property_type.nil? && !a_commercial.num_of_properties.nil?)
        if (a_commercial.num_of_properties > 1)
          if (a_commercial.property_type.eql?("Flex"))
            a_commercial.category = "condo sale"
          else
            a_commercial.category = "portfolio sale"
          end
        else
          if (a_commercial.property_type.eql?("Land"))
            a_commercial.category = "land sale"
          else
            a_commercial.category = "property sale"
          end
        end
      end

      #print "ok ", a_commercial.category, "\n" 
      a_commercial.rating = row[16].nil? ? a_commercial.rating : row[16].lstrip.rstrip 
      a_commercial.broker_company_id = row[22].nil? ? a_commercial.broker_company_id : row[22]
      a_commercial.agent_extention_id = row[23].nil? ? a_commercial.agent_extention_id : row[23]
      a_commercial.save
    end

    return a_commercial
  end

  def as_json(options = nil)
    options ||= {}
    result = super(options)
    result[:properties] = self.properties
    result[:images] = self.commercial_images.map(&:image_url)
    result[:city_info] = City.find_by_name(self.city)
    result
  end
end
