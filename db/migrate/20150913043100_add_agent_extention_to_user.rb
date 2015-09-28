class AddAgentExtentionToUser < ActiveRecord::Migration
  def change
    add_column :users, :agent_extention_id, :integer
  end
end
