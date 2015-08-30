class ApplicationController < ActionController::Base
  protect_from_forgery
  def index
    ticket =  session[:ticket]
    session[:ticket] = ''
    redirect_to "http://localhost:3031?ticket=#{ticket}" if ticket.present?
  end
end
