class CreateSchoolImages < ActiveRecord::Migration
  def change
    create_table :school_images do |t|
      t.string :image_url
      t.integer :school_id

      t.timestamps
    end
  end
end
