class AddGeoPointColumnToSchools < ActiveRecord::Migration
  def change
    add_column :schools, :geo_point, :string
  end
end
