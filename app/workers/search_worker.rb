# encoding: utf-8

class SearchWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2

  sidekiq_retry_in do |count|
    1 * (count + 1)
  end

  def perform(wid)
    wuser = WechatUser.find(wid)
    wuser.send_random_homes
    # do something
  end
end