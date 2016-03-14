class CreateMediaTable < ActiveRecord::Migration
  def change
    create_table :medias do |t|
      t.integer :reference_id
      t.string :media_id
      t.string :media_url
      t.timestamps
    end
  end
end
