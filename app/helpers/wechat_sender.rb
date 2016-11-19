# encoding: utf-8

module WechatSender

  def send_text(body)
    WechatRequest.new.send_text(to_user: self.open_id, body: body)
  end

  def send_article(body)
    WechatRequest.new.send_articles(to_user: self.open_id, body: body)
  end

  def send_random_homes
    homes = []

    HOT_AREAS.sample(4).each do |area|
      homes += Home.search(Search.new(regionValue: area), 10).sample(2)
    end

    body = home_search_items(homes, 0, self.user_id)
    WechatRequest.new.send_articles(to_user: self.open_id, body: body)
  end

  def home_search_items(homes, more_home = 0, uid)
    ticket = TicketGenerator.encrypt_uid(uid)
    homes = homes.map do |home|
      if  Home::OTHER_PROPERTY_TYPE.include?(home.meejia_type)
        title = "位于#{home.city}的#{home.home_cn.try(:lot_size)}#{home.home_cn.try(:home_type) || home.meejia_type}，#{home.price / 10000}万美金"
      else
        title = "位于#{home.city}的#{home.bed_num}卧室#{home.home_cn.try(:home_type) || home.meejia_type}，#{home.price / 10000}万美金"
      end
      {title: title,
       body: '',
       picurl: "#{CDN_HOST}/photo/#{home.images.first.try(:image_url) || 'default.jpeg'}",
       url: "#{CLIENT_HOST}/metric/home/#{home.id}/?uid=#{uid}&s=#{TRACKING_SOURCE["home_search_items"]}"}
    end

    if more_home.to_i > 0
      homes[homes.length] = {
        title: "还有#{more_home}处房源, 请回复n或N查看下一页",
        picurl: "#{CDN_HOST}/photo/default.jpeg",
        url: "#{CLIENT_HOST}/?ticket=#{ticket}#/"
      }
    end

    homes
  end

end
