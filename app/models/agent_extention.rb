class AgentExtention < ActiveRecord::Base
  validates :agent_identifier, uniqueness: true
  attr_accessible *column_names
  belongs_to :user
end