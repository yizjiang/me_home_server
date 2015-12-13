class AddListedByColumnToHomes < ActiveRecord::Migration
  def change
    add_column :homes, :listed_by, :string
  end
end
