class ApplicationController < ActionController::Base
  protect_from_forgery
  def index
    if flash[:alert] == 'You are already signed in'

    end
    if !user_signed_in?
     redirect_to "http://localhost:3031"
    end
    ticket = session[:ticket]
    ticket = get_ticket_from_uid unless ticket.present?

    p 'xxx ' + ticket
    session[:ticket] = ''
    redirect_to "http://localhost:3031?ticket=#{ticket}" if ticket.present?
  end

  def get_ticket_from_uid
    if session['warden.user.user.key']
       uid = session['warden.user.user.key'][0][0]
       return encrypt_uid(uid)
    end
    if params[:action] == 'logout'
       return ''
    end
  end

  def encrypt_uid(uid)       #TODO
    return "eqon2#{uid}xfk9"
  end
end
