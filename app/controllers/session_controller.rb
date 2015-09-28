class SessionController < ApplicationController
  def index
    uid = get_uid_from_ticket(params['ticket'])
    render json: uid
  end

  def show
    render json: {sid: session}
  end

  def get_uid_from_ticket(ticket)
    if ticket.present?
      return decode_uid(ticket)
    else
      return ''
    end
  end

  def decode_uid(ticket)
    return ticket[5..-5]
  end
end