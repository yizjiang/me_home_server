# encoding: utf-8

class NotifyUser
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(home_id, event)
    if event == 'home_sold'
      FavoriteHome.where(home_id: home_id).pluck(:uid).each do |uid|
        if wechat_user = User.find(uid).wechat_user
          wechat_user.send_home_update_on_wechat(home_id)
        end
      end
    end
  end
end
