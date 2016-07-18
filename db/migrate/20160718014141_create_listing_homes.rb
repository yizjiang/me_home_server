class CreateListingHomes < ActiveRecord::Migration
  def change
    create_table :listing_homes do |t|
      t.integer :home_id
      t.integer :user_id
      t.string :status
    end
  end
end
