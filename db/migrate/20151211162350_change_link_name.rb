class ChangeLinkName < ActiveRecord::Migration

  def up
    rename_column :homes, :link, :realtor_link
  end

  def down
   rename_column :homes, :realtor_link, :link
  end

end
