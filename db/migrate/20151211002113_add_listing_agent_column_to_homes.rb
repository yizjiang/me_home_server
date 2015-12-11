class AddListingAgentColumnToHomes < ActiveRecord::Migration
  def change
    add_column :homes, :listing_agent, :string
  end
end
