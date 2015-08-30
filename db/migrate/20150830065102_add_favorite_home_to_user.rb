class AddFavoriteHomeToUser < ActiveRecord::Migration
  def change
    create_table :favorite_homes do |t|
      t.integer :home_id
      t.integer :uid
    end
  end
end
