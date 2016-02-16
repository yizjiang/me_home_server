class ChangeAgentExtentionCityListDistrictList < ActiveRecord::Migration
  def up
    change_column :agent_extentions, :city_list, :text 
    change_column :agent_extentions, :district_list, :text 

  end

  def down
    change_column :agent_extentions, :city_list, :string
    change_column :agent_extentions, :district_list, :string
  end

end
