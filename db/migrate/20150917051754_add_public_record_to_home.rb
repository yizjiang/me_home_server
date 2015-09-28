class AddPublicRecordToHome < ActiveRecord::Migration
  def change
    create_table :public_records do |t|
      t.string :source
      t.string :property_id
      t.string :file_id
      t.integer :home_id
    end
  end
end
