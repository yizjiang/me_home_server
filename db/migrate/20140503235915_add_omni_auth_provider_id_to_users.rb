class AddOmniAuthProviderIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :omniauth_provider_id, :integer
  end
end
