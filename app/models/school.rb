class School < ActiveRecord::Base
  attr_accessible *column_names
  has_many :home_school_assignments
  has_many :homes, through: :home_school_assignments
end