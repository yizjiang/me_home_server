class RepurposeAgentRequest < ActiveRecord::Migration
  def up
    drop_table :agent_requests if table_exists?("agent_requests")
    create_table :agent_requests do |t|
      t.integer :from_user
      t.integer :to_user
      t.string :status
      t.string :request_type
      t.integer :request_context_id
      t.text :body
    end
  end

  def down
    drop_table :agent_requests
  end
end
