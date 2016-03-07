# encoding: utf-8

class WechatUser < ActiveRecord::Base
  attr_accessible *column_names
  belongs_to :user
  has_many :wechat_trackings

  after_save :send_homes_on_wechat, if: lambda {
    self.search_changed?
  }

  def send_homes_on_wechat(search = nil)
    search ||= if search = self.search
               JSON.parse(search)
             else
               {}
             end

    if !search.empty?
      searches = search['regionValue'].split(',').map do |region|
        Search.new(regionValue: region, priceMin: search['priceMin'], priceMax: search['priceMax'], bedNum: search['bedNum'])
      end

      homes = Home.search(searches) # fair divide?
      home_result(homes, self.id)
    end
  end

  def send_homes_to_wechat(zipcode, uid)
    searches = [Search.new(regionValue: zipcode)]
    homes = Home.search(searches)                        # should query id not equel
    home_result(homes, uid)
  end

  def set_redis(key, value, expired_time = 60)
    REDIS.setex("#{self.open_id}:#{key}", expired_time, value.to_s)
  end

  def delete_redis(key)
    REDIS.del("#{self.open_id}:#{key}")
  end

  def cached_input(type)
    REDIS.get("#{self.open_id}:#{type}")
  end

  def home_result(homes, uid)
    more_home = 0
    if (homes.count > 0)
      if homes.length > 10
        more_home = homes.length - 9
        showing_ids = homes[0..8].map(&:id)
        set_redis('next_ids', (homes[9..-1].map(&:id)).join(','), 300)
        homes = homes[0..8]
      else
        delete_redis('next_ids')
      end

      latest = homes.map { |h| h.last_refresh_at }.max + 1
      #self.update_attributes(last_search: latest, search_count: (self.search_count || 0) + 1)
      body = home_search_items(homes, more_home, uid)
      WechatRequest.new.send_articles(to_user: self.open_id, body: body)
    else
      WechatRequest.new.send_text(to_user: self.open_id, body: '没有在售房源')
    end
  end



  def home_search_items(homes, more_home = 0, uid)
    ticket = TicketGenerator.encrypt_uid(uid)
    homes = homes.map do |home|
      {title: "位于#{home.addr1} #{home.city}的 #{home.bed_num} 卧室 #{home.home_type}，售价：#{home.price}美金",
       body: 'nice home',
       picurl: "#{CDN_HOST}/photo/#{home.images.first.try(:image_url) || 'default.jpeg'}",
       url: "#{CLIENT_HOST}/?ticket=#{ticket}#/home_detail/#{home.id}"}
    end

    if more_home > 0
      homes[homes.length] = {
        title: "还有#{more_home}处房源, 请回复n或N查看下一页",
        picurl: "#{CDN_HOST}/photo/default.jpeg",
        url: "#{CLIENT_HOST}/?ticket=#{ticket}#/"
      }
    end

    homes
  end

end