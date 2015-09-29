class AddHomeTranslation < ActiveRecord::Migration
  def up
    unless ActiveRecord::Base.connection.table_exists? 'homes_cn'
      create_table :homes_cn, :options => 'COLLATE=utf8mb4_general_ci' do |t|
        t.integer :id
        t.text :description
      end
    end
  end
  def down
    if ActiveRecord::Base.connection.table_exists? 'homes_cn'
      drop_table :homes_cn
    end
  end
end
