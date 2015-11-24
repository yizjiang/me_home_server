class AddMoreToHomeCn < ActiveRecord::Migration
  def change
    add_column :homes_cn, :short_desc, :text
    add_column :homes_cn, :city, :string
    add_column :agent_extentions, :license_id, :string
  end
end
