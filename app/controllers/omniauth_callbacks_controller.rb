class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def all
    user = User.from_omniauth(request.env["omniauth.auth"])
    #raise request.env["omniauth.auth"].to_yaml   #how to better use oauth callback
    if user.persisted?
      flash.notice = "Signed in!"
      session[:ticket] = encrypt_uid(user.id)
      sign_in_and_redirect user
    else
      session["devise.user_attributes"] = user.attributes
      redirect_to new_user_registration_url
    end
  end

  def encrypt_uid(uid)       #TODO
    return "eqon2#{uid}xfk9"
  end

  alias_method :twitter, :all
  alias_method :facebook, :all
end
