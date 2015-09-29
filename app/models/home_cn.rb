class HomeCn < ActiveRecord::Base
  self.table_name = "homes_cn"
  belongs_to :home
  attr_accessible *column_names
end