class AddHomeStyleColumnToHomes < ActiveRecord::Migration
  def change
    add_column :homes, :home_style, :string
  end
end
