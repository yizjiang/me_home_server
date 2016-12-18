class CreateCommercialImages < ActiveRecord::Migration
  def change
    create_table :commercial_images do |t|
      t.string :image_url
      t.integer :commercial_id
      t.timestamp :created_at
      t.timestamp :updated_at

      t.timestamps
    end
  end
end
