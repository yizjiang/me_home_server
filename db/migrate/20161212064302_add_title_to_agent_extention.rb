class AddTitleToAgentExtention < ActiveRecord::Migration
  def change
    add_column :agent_extentions, :title, :string
  end
end
