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
      return TicketGenerator.decrypt_uid(ticket)
    else
      return ''
    end
  end
end