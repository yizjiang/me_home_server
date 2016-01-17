class CreateRents < ActiveRecord::Migration
  def change
    create_table :rents do |t|
      t.string :metro
      t.string :state
      t.string :city
      t.float :studio
      t.float :one_bed
      t.float :two_bed
      t.float :three_bed
      t.float :four_bed
      t.float :five_bed
      t.float :six_bed
      t.date :reported
      t.timestamps :created_at
      t.timestamps :updated_at
    end
  end
end
