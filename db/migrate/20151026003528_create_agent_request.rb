class CreateAgentRequest < ActiveRecord::Migration
  def change
    create_table :agent_requests do |t|
      t.string :open_id
      t.string :agent_identifier_list
      t.string :status
      t.string :selected_agent
      t.string :region
    end
  end
end
