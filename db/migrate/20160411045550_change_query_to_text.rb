class ChangeQueryToText < ActiveRecord::Migration
  def up
    change_column :saved_searches, :search_query, :text
  end

  def down
    change_column :saved_searches, :search_query, :string
  end
end
