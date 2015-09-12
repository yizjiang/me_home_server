class AddQrToUser < ActiveRecord::Migration
  def change
    add_column :users, :qr_code, :string
  end
end
