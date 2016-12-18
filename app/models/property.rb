class Property < ActiveRecord::Base
  attr_accessible :addr1, :building_class, :building_desc, :building_elevator, :building_parking, :building_size, :building_stories, :building_tenancy, :city, :costar_link, :county, :created_at, :geo_point, :land_parcel, :land_size, :land_use, :land_zoning, :property_type, :rating, :sale_property_id, :source_id, :state, :updated_at, :year_built, :year_renovated, :zipcode

  def self.import_simple(row)

    #p row
    uniq_condition = {source_id: row[0],
      costar_link: row[1],
      addr1: row[2],
      city: row[3],
      county: row[4],
      state: row[5],
      zipcode: row[6]
    }
    property = Property.where(uniq_condition).first_or_create
    
    property.update_attributes(property_type: row[7],
                               rating: row[8],
                               sale_property_id: row[9]
                               )
    property.save
    
    
    return property
  end


  def self.update_full(row)

     #print "--------------update row:", row, " ---------\n"
     uniq_condition = {source_id: row[0],
       costar_link: row[1],
       property_type: row[2],
       addr1: row[3],
       city: row[4],
       county: row[5],
       state: row[6],
       zipcode:row[7],
       sale_property_id: row[25]
     }

     property = Property.where(uniq_condition).first
     property.update_attributes(submarket: row[8],
                                market: row[9],
                                land_size: row[10],
                                land_parcel: row[12],
                                land_zoning: row[13],
                                land_use: row[14],
                                building_desc: row[15],
                                building_size: row[16],
                                year_built: row[17],
                                year_renovated: row[18],
                                building_stories: row[19],
                                building_class: row[20],
                                building_tenancy: row[21],
                                building_parkging: row[22],
                                building_elevators: row[23],
                                geo_point: row[24]
                                )  unless property.nil?

      property.save unless property.nil?

  end


  
end
