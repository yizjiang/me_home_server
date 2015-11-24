class WechatUser < ActiveRecord::Base
  attr_accessible *column_names
  has_many :wechat_trackings
end