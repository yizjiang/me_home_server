class MetricController < ApplicationController

  def display_all
  end

  def display_all_users
    list = REDIS.keys("UserView:*").map{|x| x[9..-1]}
    results = {}
    u_list = User.where(id: list)
    u_list.each do |x|
      results[x.id.to_s] = {}
      results[x.id.to_s]["user_name"] = x.wechat_user.nickname
      results[x.id.to_s]["home_list"] = REDIS.hgetall("UserView:" + x.id.to_s)
      results[x.id.to_s]["source_list"] = REDIS.hgetall("UserViewSource:" + x.id.to_s)
    end
    render json: results.to_json
  end

  def display_all_houses
    arr = []
    results = {}
    hlist = REDIS.hgetall("UserView:" + params["id"])
    hlist.each{|k, v| arr << k.to_i}
    hresult = Home.where(id: arr)
    hresult.each do |x|
      results[x.id.to_s] = x.attributes
      results[x.id.to_s]["view_times"] = hlist[x.id.to_s]
    end
    render json: results.to_json
  end

  def house_list
    list = REDIS.keys("HouseViewed:*").map{|x| x[12..-1]}
    results = {}
    list.each do |x|
      r = REDIS.hgetall("HouseViewed:" + x)
      results[x] = r.each{|k, v| r[k] = v.to_i}
    end
    render json: results.to_json
  end

  def metric_tracking
    uid = request.headers['HTTP_UID']
    user = User.find(uid)
    WechatTracking.where(wechat_user_id: user.wechat_user.try(:id), tracking_type: 'home viewed', item: params[:home_id]).first_or_create
    render json: []
  end

  def metric_tracking_h
    uid = request.headers['HTTP_UID']
    hid = params["hid"]
    key = (params["s"] ? params["s"] : "other")
    unless REDIS.exists("Cache:" + request.env["REMOTE_ADDR"] + ":" + key)
      REDIS.setex("Cache:" + request.env["REMOTE_ADDR"] + ":" + key, 5, "1")
      REDIS.hincrby("HouseViewed:" + hid.to_s, "total", 1)
      REDIS.hincrby("HouseViewed:" + hid.to_s, key, 1)
      if uid
        REDIS.hincrby("UserView:" + uid.to_s, params["hid"], 1)
        REDIS.hincrby("UserViewSource:" + uid.to_s, key, 1)
        MetricHomeTracking.create({uid: uid.to_i, hid: hid.to_i, source: key, viewed_time: Time.now.to_i})
      end
    end
    render :nothing => true, :status => 200, :content_type => 'text/html'
  end

end
