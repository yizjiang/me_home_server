class CreateAgentReviews < ActiveRecord::Migration
  def change
    create_table :agent_reviews do |t|
      t.integer :agent_extention_id
      t.integer :poster_id
      t.integer :recommendation_rate
      t.integer :knowledge_rate
      t.integer :expertise_rate
      t.integer :responsiveness_rate
      t.integer :negotiation_skill_rate
      t.text :comment
      t.string :source_reviewer
      t.string :source
      t.integer :source_post_id

      t.timestamps
    end
  end
end
