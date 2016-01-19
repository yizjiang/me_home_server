class AddPriceColumnToPublicRecords < ActiveRecord::Migration
  def change
    add_column :public_records, :price, :float
  end
end
