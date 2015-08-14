class HomeSchoolAssignment < ActiveRecord::Base
  belongs_to :home
  belongs_to :school
  attr_accessible *column_names
end