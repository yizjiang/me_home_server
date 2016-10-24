class AddAgentMediaIdToArticle < ActiveRecord::Migration
  def change
    create_table :agent_articles do |t|
      t.string :media_id
      t.text :content
      t.string :url
      t.string :title
      t.string :digest
      t.string :author
      t.string :content_source_url
      t.integer :user_id
      t.string :thumb_media_id
      t.timestamps
    end
  end
end
