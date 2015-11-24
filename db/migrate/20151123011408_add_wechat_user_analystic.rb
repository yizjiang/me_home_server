class AddWechatUserAnalystic < ActiveRecord::Migration
  def change
    add_column :wechat_users, :last_search, :datetime
    add_column :wechat_users, :search_count, :integer

    create_table :wechat_trackings do |t|
      t.string :tracking_type
      t.integer :wechat_user_id
      t.text :item
    end
  end
end
