class AddGeoPointToCities < ActiveRecord::Migration
  def change
    add_column :cities, :geo_point, :string
  end
end
