class AddStateColumnToCities < ActiveRecord::Migration
  def change
    add_column :cities, :state, :string
  end
end
