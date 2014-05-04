class CreateOmniAuthProvider < ActiveRecord::Migration
  def change
    create_table :omni_auth_providers do |t|
      t.string :name
      t.string :app_id
      t.string :app_secret
    end
  end
end
