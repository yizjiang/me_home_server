class AddQuestionToUser < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :text
      t.integer :uid
    end
  end
end
