class AuthProvider < ActiveRecord::Base
  self.table_name = "auth_provider"
  attr_accessible :name, :access_token, :access_token_secret, :external_id
end