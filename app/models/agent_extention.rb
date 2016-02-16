require 'street_address'

class AgentExtention < ActiveRecord::Base
#  validates :agent_identifier, uniqueness: true
#  validates :agent_identifier, :license_id, presence: true
  attr_accessible *column_names
  belongs_to :user

  def self.importer(broker_agent)
    
     biz_name = broker_agent[0].nil? ? nil : broker_agent[0].lstrip.rstrip
     if !(biz_name.nil? || biz_name.empty?)
       biz_addr = broker_agent[1].nil? ? nil : broker_agent[1].lstrip.rstrip
       biz_city = broker_agent[2].nil? ? nil : broker_agent[2].lstrip.rstrip
       biz_state = broker_agent[3].nil? ? nil : broker_agent[3].lstrip.rstrip
       biz_zipcode = broker_agent[4].nil? ? nil : broker_agent[4].lstrip.rstrip
       if ((biz_zipcode.nil? || biz_zipcode.empty?)  && !(biz_addr.nil? || biz_addr.empty?))
         address = StreetAddress::US.parse(biz_addr)    #address = biz_addr.match(/^([^,]*),\s*(\w*)\s*(\d*)?$/)
         if !(address.nil?)
           biz_city = address.city
           biz_state = address.state
           biz_zipcode = address.postal_code
           biz_addr = address.to_s(:line1)
         end 
       end
     
       if (!biz_zipcode.nil?  && !biz_state.nil? && !biz_city.nil? && !biz_addr.nil? ) 
         broker_company = BrokerCompany.where(name:biz_name, addr:biz_addr, city:biz_city, state:biz_state, zipcode:biz_zipcode).first_or_create
         broker_company.country = "USA"
         broker_company.phone = broker_agent[6]
         broker_company.save
         
         if (!broker_agent[17].nil? && broker_agent[17].match(/[-+]?[0-9]+/))
#           p broker_agent[17]         
           agent = AgentExtention.where(city_area:broker_agent[15].lstrip.rstrip, license_id:broker_agent[17], license_state:biz_state).first_or_create    
#           p agent
           agent.first_name = broker_agent[7].nil? ? nil : broker_agent[7].lstrip.rstrip
           agent.middle_name = broker_agent[8].nil? ? nil : broker_agent[8].lstrip.rstrip
           agent.last_name = broker_agent[9].nil? ? nil : broker_agent[9].lstrip.rstrip
           agent.cn_name = broker_agent[10].nil? ? nil : broker_agent[10].lstrip.rstrip
           agent.phone = broker_agent[11].nil? ? nil : broker_agent[11].lstrip.rstrip
           agent.wechat = broker_agent[12].nil? ? nil : broker_agent[12].lstrip.rstrip
           agent.mail = broker_agent[13].nil? ? nil : broker_agent[13].lstrip.rstrip
           agent.url = broker_agent[14].nil? ? nil : broker_agent[14].lstrip.rstrip
           agent.license_year = broker_agent[16].nil? ? nil : broker_agent[16].lstrip.rstrip
           agent.description = broker_agent[18].nil? ? nil : broker_agent[18].lstrip.rstrip
           agent.photo_url = broker_agent[19].nil? ? nil : broker_agent[19].lstrip.rstrip[10..-5]
           agent.city_list = broker_agent[20].nil? ? nil : broker_agent[20].lstrip.rstrip
           agent.district_list = broker_agent[21].nil? ? nil : broker_agent[21].lstrip.rstrip
           agent.source = broker_agent[22].nil? ? nil : broker_agent[22].lstrip.rstrip
           agent.source_id = broker_agent[23].nil? ? nil : broker_agent[23].lstrip.rstrip
           agent.status = "pending"
           agent.broker_company_id = broker_company.id
 #          p "before save"
           agent.save
  #         p agent.id
           return agent
         end 
       end     
     end
  end 
  

end
