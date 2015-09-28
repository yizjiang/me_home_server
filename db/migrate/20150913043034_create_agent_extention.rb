class CreateAgentExtention < ActiveRecord::Migration
  def change
    create_table :agent_extentions do |t|
      t.string :page_config
      t.string :agent_identifier
      t.integer :user_id
    end
  end
end
