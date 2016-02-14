class RemoveAddressIdFromSchools < ActiveRecord::Migration
  def up
    remove_column :schools, :address_id
  end

  def down
    add_column :schools, :address_id, :integer
  end
end
