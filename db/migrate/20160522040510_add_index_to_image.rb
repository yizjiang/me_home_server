class AddIndexToImage < ActiveRecord::Migration
  def change
    add_index :images, :home_id
    add_index :home_school_assignments, :home_id
  end
end
