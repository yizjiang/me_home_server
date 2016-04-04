# encoding: utf-8

class MediaWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  sidekiq_retries_exhausted do |msg|
    WechatRequest.new(true).send_text(to_user: msg['args'][0], body: '无法获取音频文件')
  end

  def perform(wid, mid, media_from_agent, send_to_wechat)
    media = Media.find(mid)
    request, receiver_request = if media_from_agent
                [WechatRequest.new(true), WechatRequest.new]
              else
                [WechatRequest.new, WechatRequest.new(true)]
              end
    unless(media.receiver_media_id)
      local_file = request.download_media(media.media_id)
      media.media_url = "#{SERVER_HOST}/wechat_media/#{media.media_id}"
      receiver_media_id = receiver_request.upload_media(local_file)
      media.receiver_media_id = receiver_media_id
      media.save
    end
    if send_to_wechat
      receiver_request.send_audio(to_user: wid, mid: media.receiver_media_id)
    end
  end
end