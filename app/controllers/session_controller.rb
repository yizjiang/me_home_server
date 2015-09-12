class SessionController < ApplicationController
  def index
    uid = get_uid_from_ticket(params['ticket'])
    render json: uid
  end

  def show
    render json: {sid: session}
  end

  def get_uid_from_ticket(ticket)
    value = REDIS.get(ticket)
    REDIS.del(ticket)
    return value if value
    return ''
  end
end