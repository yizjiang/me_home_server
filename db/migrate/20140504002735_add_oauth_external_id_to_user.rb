class AddOauthExternalIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :oauth_external_id, :string
  end
end
