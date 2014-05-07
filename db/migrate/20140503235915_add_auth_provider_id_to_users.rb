class AddAuthProviderIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :auth_provider_id, :integer
  end
end
