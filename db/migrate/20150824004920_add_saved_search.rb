class AddSavedSearch < ActiveRecord::Migration
  def change
    create_table :saved_searches do |t|
      t.string :search_query
      t.integer :uid
    end
  end
end
