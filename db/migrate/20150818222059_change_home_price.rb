class ChangeHomePrice < ActiveRecord::Migration
  def up
    change_column :homes, :price, :float
  end

  def down
    change_column :homes, :price, :string
  end
end
