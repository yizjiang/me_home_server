class ApplicationController < ActionController::Base
  protect_from_forgery
  def index
    redirect_url =  params[:redirect_url] || File.join(CLIENT_HOST, 'auth_callback')

    if flash[:alert] == 'You are already signed in'
      redirect_to "#{redirect_url}?ticket=#{get_ticket_from_uid}"
    end
    if !user_signed_in?
     redirect_to "#{redirect_url}"
    end
    ticket = session[:ticket]
    ticket = get_ticket_from_uid unless ticket.present?
    session[:ticket] = ''
    redirect_to "#{redirect_url}?ticket=#{ticket}" if ticket.present?
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
    return "74651#{uid}1329"
  end
end
