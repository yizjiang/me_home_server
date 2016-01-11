class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :username, presence: true

  has_one :auth_provider, class_name: AuthProvider
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :username, :password_confirmation, :remember_me, :auth_provider_id, :qr_code,
                  :agent_identifier, :agent_license_id, :agent_extention_id#validate uniqueness of omniauth and external id

  has_many :saved_searches, foreign_key: 'uid'
  has_many :questions, foreign_key: 'uid'
  has_many :favorite_homes, foreign_key: 'uid'
  has_many :homes, through: :favorite_homes do
    def just_address
      select([:id, :addr1])
    end
  end
  has_many :answers, foreign_key: 'uid'
  has_one :agent_extention
  has_one :wechat_user, foreign_key: 'user_id'

  after_create :assign_agent_extension, if: lambda{self.agent_extention_id.present?}

  def as_json(options=nil)
    options ||= {}
    result = super(options)
    unless options[:include_details] == false
      result[:homes] = self.homes
      result[:saved_searches] = self.saved_searches
    end
    result[:agent_extention] = self.agent_extention
    result[:wechat_user] = self.wechat_user
    result
  end

  def agent_license_id
    ''
  end

  def agent_identifier
    ''
  end

  def create_agent_extension(identifier, license_id)
    if identifier.present? && license_id.present?
      agent_ex = AgentExtention.find_or_create_by_agent_identifier_and_license_id(identifier.parameterize.underscore, license_id).id
      self.agent_extention_id = agent_ex
    end
  end

  def assign_agent_extension
    if self.agent_extention_id
      agent_ex = AgentExtention.find(self.agent_extention_id)
      agent_ex.update_attributes(user_id: self.id)
    end
  end

  def create_search(query)
    SavedSearch.find_or_create_by_search_query_and_uid(JSON(query), self.id) do |search|
      search.uid = self.id
    end
    if(saved_searches.count > 5)
      saved_searches.first.delete
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
    p "xxx #{params}"
    if session["devise.user_attributes"]
      agent_identifier,agent_license_id = params[:agent_identifier], params[:agent_license_id]
      p "xxx #{agent_identifier} #{agent_license_id}"
      user = new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
      if agent_identifier.present? && agent_license_id.present?
        user.create_agent_extension(agent_identifier, agent_license_id)
      end
      user
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
