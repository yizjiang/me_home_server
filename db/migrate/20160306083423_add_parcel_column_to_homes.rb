class AddParcelColumnToHomes < ActiveRecord::Migration
  def change
    add_column :homes, :parcel, :string
  end
end
