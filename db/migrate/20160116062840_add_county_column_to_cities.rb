class AddCountyColumnToCities < ActiveRecord::Migration
  def change
    add_column :cities, :county, :string
  end
end
