# encoding: utf-8

class WechatUser < ActiveRecord::Base
  attr_accessible *column_names
  belongs_to :user
  has_many :wechat_trackings

  after_save :send_homes_on_wechat, if: lambda {
    self.search_changed?
  }

  def send_homes_on_wechat(search = nil)
    p 'ere'
    search ||= if search = self.search
               JSON.parse(search)
             else
               {}
             end

    if !search.empty?
      searches = search['regionValue'].split(',').map do |region|
        Search.new(regionValue: region, priceMin: search['priceMin'], priceMax: search['priceMax'], bedNum: search['bedNum'])
      end

      homes = Home.search(searches, 10, last_search || Time.at(-284061600)) # fair divide?
      if (homes.count > 0)
        body = home_search_items(homes)
        begin
          WechatRequest.new.send_articles(to_user: self.open_id, body: body)
        rescue Exception => e
          Rails.logger.error(e)
          true
        end
      else
        WechatRequest.new.send_text(to_user: self.open_id, body: '没有在售房源')
      end
    end
  end


  def home_search_items(homes)
    ticket = TicketGenerator.encrypt_uid(self.user_id)
    homes.map do |home|
      {title: "位于#{home.addr1} #{home.city}的 #{home.bed_num} 卧室 #{home.home_type}，售价：#{home.price}美金",
       description: 'nice home',
       picurl: "#{CDN_HOST}/photo/#{home.images.first.try(:image_url) || 'default.jpeg'}",
       url: "#{CLIENT_HOST}/?ticket=#{ticket}#/home_detail/#{home.id}"}
    end
  end

end