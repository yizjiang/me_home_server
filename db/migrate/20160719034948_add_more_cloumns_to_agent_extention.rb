class AddMoreCloumnsToAgentExtention < ActiveRecord::Migration
  def change
    add_column :agent_extentions, :license_type, :string
    add_column :agent_extentions, :license_issue, :date
    add_column :agent_extentions, :license_expire, :date
    add_column :agent_extentions, :mailing_adress, :string
  end
end
