class AddMoreToHomeCn < ActiveRecord::Migration
  def change
    unless column_exists? :homes_cn, :short_desc
      add_column :homes_cn, :short_desc, :text
    end
    unless column_exists? :homes_cn, :city
      add_column :homes_cn, :city, :string
    end
    add_column :agent_extentions, :license_id, :string
  end
end
