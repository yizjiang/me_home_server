class Answer < ActiveRecord::Base
  belongs_to :user, foreign_key: 'uid'
  belongs_to :question
  attr_accessible *column_names
end