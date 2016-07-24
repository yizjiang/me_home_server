class RemoveLicenseYearFromAgentExtention < ActiveRecord::Migration
  def up
    remove_column :agent_extentions, :license_year
  end

  def down
    add_column :agent_extentions, :license_year, :string
  end
end
