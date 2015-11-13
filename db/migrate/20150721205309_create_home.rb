class CreateHome < ActiveRecord::Migration
  def change
    create_table :homes do |t|
      t.string :addr1
      t.string :addr2
      t.string :city
      t.string :county
      t.string :state
      t.integer :zipcode
      t.datetime :last_refresh_at
      t.datetime :created_at
      t.string :link
      t.text :description
      t.integer :bed_num
      t.integer :bath_num
      t.integer :indoor_size
      t.integer :lot_size
      t.string :price
      t.float :unit_price
      t.string :home_type
      t.integer :year_built
      t.string :neighborhood
      t.integer :stores
      t.string :status
    end
  end
end
