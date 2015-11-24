class AgentExtention < ActiveRecord::Base
  validates :agent_identifier, uniqueness: true
  validates :agent_identifier, :agent_license_id, presence: true
  attr_accessible *column_names
  belongs_to :user
end