# encoding: utf-8

class WechatUser < ActiveRecord::Base
  include WechatSender

  attr_accessible *column_names
  belongs_to :user
  has_many :wechat_trackings

  after_create :after_subscribe

  after_save :send_homes_on_wechat, if: lambda {
    self.search_changed?
  }

  def after_subscribe
    SubscribeWorker.perform_async(self.id)
  end

  def send_home_on_wechat(home_id, to_agent = false)
    body = home_search_items([Home.find(home_id)], 0, self.id)

    if(to_agent)
      WechatRequest.new(true).send_articles(to_user: self.open_id, body: body)
    else
      WechatRequest.new.send_articles(to_user: self.open_id, body: body)
    end
  end

  def send_homes_on_wechat(search = nil)
    search ||= if search = self.search
               JSON.parse(search)
             else
               {}
             end

    if !search.empty?
      searches = search['regionValue'].split(',').map do |region|
        Search.new(regionValue: region, priceMin: search['priceMin'], priceMax: search['priceMax'], bedNum: search['bedNum'], home_type: search['home_type'])
      end

      homes = Home.search(searches).shuffle # fair divide?
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
      if homes.length > 8
        more_home = homes.length - 7
        showing_ids = homes[0..6].map(&:id)
        set_redis('next_ids', (homes[7..-1].map(&:id)).join(','), 300)
        show_homes = homes[0..6]
      else
        delete_redis('next_ids')
      end

      latest = homes.map { |h| h.last_refresh_at }.max + 1
      #self.update_attributes(last_search: latest, search_count: (self.search_count || 0) + 1)
      body = home_search_items(show_homes, more_home, uid)
      WechatRequest.new.send_articles(to_user: self.open_id, body: body)
      ReplyWorker.perform_async(self.open_id, 'home_map', homes.map(&:id).join(','))
    else
      WechatRequest.new.send_text(to_user: self.open_id, body: '没有在售房源')
    end
  end

end