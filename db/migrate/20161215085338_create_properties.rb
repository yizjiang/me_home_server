class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties do |t|
      t.string :property_type
      t.string :addr1
      t.string :city
      t.string :county
      t.string :state
      t.integer :zipcode
      t.integer :rating
      t.float :land_size
      t.string :land_parcel
      t.string :land_zoning
      t.string :land_use
      t.string :building_desc
      t.float :building_size
      t.integer :year_built
      t.integer :year_renovated
      t.integer :building_stories
      t.string :building_class
      t.string :building_tenancy
      t.string :building_parking
      t.string :building_elevator
      t.string :geo_point
      t.string :sale_property_id
      t.string :source_id
      t.string :costar_link
      t.timestamp :created_at
      t.timestamp :updated_at
    end
  end
end
