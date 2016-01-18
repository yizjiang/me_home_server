class AddEventColumnToPublicRecords < ActiveRecord::Migration
  def change
    add_column :public_records, :event, :string
  end
end
