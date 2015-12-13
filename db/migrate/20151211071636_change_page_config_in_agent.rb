class ChangePageConfigInAgent < ActiveRecord::Migration
  def change
    change_column :agent_extentions, :page_config, :text
  end
end
