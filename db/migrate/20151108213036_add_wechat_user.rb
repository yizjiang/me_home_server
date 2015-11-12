class AddWechatUser < ActiveRecord::Migration
  def change
    create_table :wechat_users do |t|
      t.string :open_id
      t.string :agent_id
      t.text :search
      t.integer :user_id
      t.string :nickname
      t.string :head_img_url
    end
  end
end
