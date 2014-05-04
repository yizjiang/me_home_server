class OmniAuthProvider < ActiveRecord::Base
  attr_accessible :name, :app_id, :app_secret
  belongs_to :user
end