class CreateAuthProvider < ActiveRecord::Migration
  def change
    create_table :auth_provider do |t|
      t.string :name
      t.string :access_token
      t.string :access_token_secret
      t.string :external_id
    end
  end
end
