class AddMailingAddressToAgentExtention < ActiveRecord::Migration
  def change
    add_column :agent_extentions, :mailing_address, :string
  end
end
