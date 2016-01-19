class AddRecordDateColumnToPublicRecords < ActiveRecord::Migration
  def change
    add_column :public_records, :record_date, :date
  end
end
