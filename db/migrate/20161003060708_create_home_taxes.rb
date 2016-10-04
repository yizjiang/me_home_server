class CreateHomeTaxes < ActiveRecord::Migration
  def change
    create_table :home_taxes do |t|
      t.string :year
      t.float :taxes
      t.float :land_value
      t.float :added_value
      t.integer :home_id
      t.timestamps :created_at
      t.timestamps :updated_at
    end
  end
end
