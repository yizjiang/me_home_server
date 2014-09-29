class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # assaconfirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :post_cards
  has_one :auth_provider, class_name: AuthProvider
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :username, :password_confirmation, :remember_me, :auth_provider_id#validate uniqueness of omniauth and external id

  def self.from_omniauth(auth)
    auth_provider = AuthProvider.find_or_create_by_name_and_external_id(name: auth.provider, external_id: auth.uid, access_token: auth.credentials.token, access_token_secret: auth.credentials.secret)
    User.find_or_create_by_auth_provider_id(auth_provider_id: auth_provider.id, username: auth.info.nickname)
  end

  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def password_required?
    super && auth_provider_id.blank?
  end

  def update_with_password(params, *options)   #need have password when omniauth
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end
end
