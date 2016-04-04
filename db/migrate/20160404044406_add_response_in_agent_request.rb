class AddResponseInAgentRequest < ActiveRecord::Migration
  def change
    add_column :agent_requests, :response, :text
  end
end
