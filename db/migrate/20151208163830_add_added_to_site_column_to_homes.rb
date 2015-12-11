class AddAddedToSiteColumnToHomes < ActiveRecord::Migration
  def change
    add_column :homes, :added_to_site, :datetime
  end
end
