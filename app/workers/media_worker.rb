# encoding: utf-8

class MediaWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  sidekiq_retries_exhausted do |msg|
    WechatRequest.new.send_text(to_user: msg['args'][0], body: '无法获取音频文件')
  end

  def perform(wid, mid)
    mid = Media.find(mid).media_id
    #media_url = WechatRequest.new.download_media(mid)
    WechatRequest.new.send_audio(to_user: wid, mid: mid)
    # do something
  end
end