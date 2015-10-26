class AddOpenIdToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :open_id, :string
  end
end
