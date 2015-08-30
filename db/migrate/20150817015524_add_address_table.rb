class AddAddressTable < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :addr1
      t.string :addr2
      t.string :city
      t.string :county
      t.string :state
      t.integer :zipcode
      t.integer :entity_id
    end
  end
end
