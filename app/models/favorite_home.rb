class FavoriteHome < ActiveRecord::Base
  belongs_to :user, foreign_key: 'uid'
  belongs_to :home, foreign_key: 'home_id'
  attr_accessible *column_names
end