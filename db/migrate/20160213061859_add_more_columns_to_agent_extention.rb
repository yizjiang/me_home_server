class AddMoreColumnsToAgentExtention < ActiveRecord::Migration
  def change
    add_column :agent_extentions, :first_name, :string
    add_column :agent_extentions, :middle_name, :string
    add_column :agent_extentions, :last_name, :string
    add_column :agent_extentions, :cn_name, :string
    add_column :agent_extentions, :phone, :string
    add_column :agent_extentions, :wechat, :string
    add_column :agent_extentions, :mail, :string
    add_column :agent_extentions, :url, :string
    add_column :agent_extentions, :license_state, :string
    add_column :agent_extentions, :license_year, :string
    add_column :agent_extentions, :description, :text
    add_column :agent_extentions, :photo_url, :string
    add_column :agent_extentions, :status, :string
    add_column :agent_extentions, :city_area, :string
    add_column :agent_extentions, :city_list, :string
    add_column :agent_extentions, :district_list, :string
    add_column :agent_extentions, :source, :string
    add_column :agent_extentions, :source_id, :string
    add_column :agent_extentions, :broker_company_id, :integer
  end
end
