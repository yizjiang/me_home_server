class CreatePostCards < ActiveRecord::Migration
  def change
    create_table :post_cards do |t|
      t.string :content
      t.integer :user_id

      t.timestamps
    end
  end
end
