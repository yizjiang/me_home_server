class Media < ActiveRecord::Base
  self.table_name = 'medias'
  belongs_to :question, foreign_key: 'reference_id'
  attr_accessible *column_names
end