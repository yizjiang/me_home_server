class AddCreateToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :created_at, :datetime
  end
end
