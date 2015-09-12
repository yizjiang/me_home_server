class Question < ActiveRecord::Base
  belongs_to :user
  has_many :answers, foreign_key: 'qid'
  attr_accessible *column_names

  scope :unanswered, lambda{ |uid| includes(:answers).where(accepted_aid: nil).select{|q| q.answers.index{|a| a.uid == 5} == nil} }    #TODO more efficient query

  def create_answer(text, replyee_id)
    self.answers << Answer.find_or_create_by_uid_and_body(replyee_id, text)
  end
end