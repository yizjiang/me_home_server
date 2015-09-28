class PublicRecord < ActiveRecord::Base
  belongs_to :home
  attr_accessible *column_names
end