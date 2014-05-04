class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :post_cards
  has_many :auth_provider, class_name: OmniAuthProvider
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :username, :password_confirmation, :remember_me, :omniauth_provider_id, :oauth_external_id #validate uniqueness of omniauth and external id

  def self.from_omniauth(auth)
    provider_id = OmniAuthProvider.find_by_name(auth.provider).id
    where(omniauth_provider_id: provider_id, oauth_external_id: auth.uid).first_or_create do |user|
      user.omniauth_provider_id = provider_id
      user.oauth_external_id = auth.uid
      user.username = auth.info.nickname
    end
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
    super && omniauth_provider_id.blank?
  end

  def update_with_password(params, *options)   #need have password when omniauth
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end
end
