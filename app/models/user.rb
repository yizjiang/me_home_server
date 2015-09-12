class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one :auth_provider, class_name: AuthProvider
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :username, :password_confirmation, :remember_me, :auth_provider_id, :qr_code#validate uniqueness of omniauth and external id

  has_many :saved_searches, foreign_key: 'uid'
  has_many :questions, foreign_key: 'uid'
  has_many :favorite_homes, foreign_key: 'uid'
  has_many :homes, through: :favorite_homes
  has_many :answers, foreign_key: 'uid'

  def create_search(query)
    SavedSearch.find_or_create_by_search_query(JSON(query.slice(*%w(regionValue priceMin priceMax)))) do |search|
      search.uid = self.id
    end
  end

  def add_favorite(home_id)
    FavoriteHome.find_or_create_by_uid_and_home_id(self.id, home_id)
  end

  def remove_favorite(home_id)
    FavoriteHome.find_by_uid_and_home_id(self.id, home_id).destroy
  end

  def create_question(question)
    Question.find_or_create_by_text(question[:text]) do |q|
      q.uid = self.id
    end
  end


  def self.from_omniauth(auth)
    auth_provider = AuthProvider.find_or_create_by_name_and_external_id(name: auth.provider, external_id: auth.uid, access_token: auth.credentials.token, access_token_secret: auth.credentials.secret)
    user = User.find_or_create_by_auth_provider_id(auth_provider_id: auth_provider.id)
    user.update_attributes(email: auth.info.email, username:auth.info.try(:nickname))
    user
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
