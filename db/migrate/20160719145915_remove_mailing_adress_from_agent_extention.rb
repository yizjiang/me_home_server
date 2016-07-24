class RemoveMailingAdressFromAgentExtention < ActiveRecord::Migration
  def up
    remove_column :agent_extentions, :mailing_adress
  end

  def down
    add_column :agent_extentions, :mailing_adress, :string
  end
end
