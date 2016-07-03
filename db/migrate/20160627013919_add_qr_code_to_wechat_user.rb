class AddQrCodeToWechatUser < ActiveRecord::Migration
  def change
    add_column :wechat_users, :qrcode, :string
  end
end
