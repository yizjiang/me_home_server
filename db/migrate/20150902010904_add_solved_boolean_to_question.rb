class AddSolvedBooleanToQuestion < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.integer :uid
      t.integer :qid
      t.string :body
    end
  end
end
