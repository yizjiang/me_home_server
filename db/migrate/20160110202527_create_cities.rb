class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :name
      t.integer :population
      t.float :income
      t.string :above_bachelor
      t.float :crime
      t.float :us_crime
      t.string :unemploy
      t.string :state_unemploy
      t.string :hispanics
      t.string :asian
      t.string :caucasion
      t.string :black
      t.float :PMI
      t.timestamps :created_at
      t.timestamps :updated_at
    end
  end
end
