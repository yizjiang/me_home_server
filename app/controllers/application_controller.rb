class ApplicationController < ActionController::Base
  protect_from_forgery
  def index
    if flash[:alert] == 'You are already signed in'
      redirect_to "#{CLIENT_HOST}?ticket=#{get_ticket_from_uid}"
    end
    if !user_signed_in?
     redirect_to "#{CLIENT_HOST}"
    end
    ticket = session[:ticket]
    ticket = get_ticket_from_uid unless ticket.present?
    session[:ticket] = ''
    redirect_to "#{CLIENT_HOST}?ticket=#{ticket}" if ticket.present?
  end

  def get_ticket_from_uid
    if params[:user_action] == 'logout'
       return ''
    end
    if session['warden.user.user.key']
       uid = session['warden.user.user.key'][0][0]
       return encrypt_uid(uid)
    end
  end

  def encrypt_uid(uid)       #TODO
    return "eqon2#{uid}xfk9"
  end
end
