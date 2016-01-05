class AddGeoPointColumnToHomes < ActiveRecord::Migration
  def change
    add_column :homes, :geo_point, :string
  end
end
