# encoding: utf-8

class QrcodeWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  sidekiq_retries_exhausted do |msg|
    WechatRequest.new.send_text(to_user: msg['args'][0], body: '无法保存二维码，请重试')
  end

  def perform(mid, wid)
    local_file = WechatRequest.new.download_media(mid, './public/customer_qr')
    qr_url = File.join(SERVER_HOST, local_file[9..-1])
    WechatUser.find(wid).update_attributes(qrcode: qr_url)
  end
end