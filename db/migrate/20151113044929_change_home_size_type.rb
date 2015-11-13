class ChangeHomeSizeType < ActiveRecord::Migration
  def change
    change_column :homes, :indoor_size, :string
    change_column :homes, :lot_size, :string
  end
end
