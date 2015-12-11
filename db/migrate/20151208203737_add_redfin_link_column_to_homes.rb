class AddRedfinLinkColumnToHomes < ActiveRecord::Migration
  def change
    add_column :homes, :redfin_link, :string
  end
end
