class Address < ActiveRecord::Base
  attr_accessible *column_names
  belongs_to :school, foreign_key: 'entity_id'
end