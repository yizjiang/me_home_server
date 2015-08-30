class SavedSearch < ActiveRecord::Base
  belongs_to :user
  attr_accessible *column_names
end