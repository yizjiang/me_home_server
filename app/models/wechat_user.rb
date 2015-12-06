class WechatUser < ActiveRecord::Base
  attr_accessible *column_names
  belongs_to :user
  has_many :wechat_trackings
end