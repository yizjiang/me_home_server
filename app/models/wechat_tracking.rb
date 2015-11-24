class WechatTracking < ActiveRecord::Base
  attr_accessible *column_names
  belongs_to :wechat_user
end