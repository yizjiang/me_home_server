# encoding: utf-8

class AgentFetcher
  include Sidekiq::Worker
  sidekiq_options retry: 3

  sidekiq_retry_in do |count|
    1 * (count + 1)
  end

  def perform(extention_id, license_id)
    agent_ext = AgentExtention.find(extention_id)
    url = "http://www2.dre.ca.gov/PublicASP/pplinfo.asp?License_id=#{license_id}"
    response = Typhoeus.get(url).body
  end
end
