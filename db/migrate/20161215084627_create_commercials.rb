class CreateCommercials < ActiveRecord::Migration
  def change
    create_table :commercials do |t|
      t.string :sale_type
      t.string :category
      t.string :status
      t.string :name
      t.integer :rating
      t.float :size
      t.float :price
      t.float :price_sf
      t.float :cap_rate
      t.timestamp :on_market
      t.datetime :last_updated
      t.integer :num_of_properties
      t.string :land_size
      t.integer :rating
      t.string :property_type
      t.string :addr1
      t.string :city
      t.string :county
      t.string :state
      t.integer :zipcode
      t.string :geo_point
      t.integer :year_b_r
      t.string :submarket
      t.string :market
      t.integer :stories
      t.string :broker_company_id
      t.string :agent_extention_id
      t.string :source_id
      t.string :costar_link
      t.timestamp :created_at
      t.timestamp :updated_at
    end
  end
end
