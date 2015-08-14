class CreateImage < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :image_url
      t.integer :home_id
    end
  end
end
