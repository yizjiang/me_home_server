class AddAcceptedAnswerIdToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :accepted_aid, :integer
  end
end
