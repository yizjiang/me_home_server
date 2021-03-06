class AgentExtention < ActiveRecord::Base
#  validates :agent_identifier, uniqueness: true
#  validates :agent_identifier, :license_id, presence: true
  attr_accessible *column_names
  belongs_to :user

  def self.import_one(firstname, lastname, title, city, state, phone,email, company_id)
     #print "--", firstname, ",", lastname, ",", title, ",", phone, ",", email, ",", company_id, "\n"
    uniq_condition =
      {
      first_name: firstname,
      last_name: lastname,
      title: title,
      city_area: city,
      license_state: state,
      status: "pending",
      mail: email,
      broker_company_id: company_id
    }
    
    agent = AgentExtention.where(uniq_condition).first
    agent = AgentExtention.new(uniq_condition) if agent.nil?
    agent.update_attributes(phone: phone, description: "commercial property contact")
    return agent
  end

  def self.importer(broker_agent)
    biz_license_id = broker_agent[7].nil? ? nil : broker_agent[7].lstrip.rstrip
    biz_name = broker_agent[0].nil? ? nil : broker_agent[0].lstrip.rstrip
    biz_addr = broker_agent[1].nil? ? nil : broker_agent[1].lstrip.rstrip
    biz_city = broker_agent[2].nil? ? nil : broker_agent[2].lstrip.rstrip
    biz_state = broker_agent[3].nil? ? nil : broker_agent[3].lstrip.rstrip
    biz_zipcode = broker_agent[4].nil? ? nil : broker_agent[4].lstrip.rstrip
    
    if (biz_license_id.nil? && biz_name.nil?)  
      return
    end 

    if ((biz_zipcode.nil? || biz_zipcode.empty?)  && !(biz_addr.nil? || biz_addr.empty?))
      address = StreetAddress::US.parse(biz_addr)    #address = biz_addr.match(/^([^,]*),\s*(\w*)\s*(\d*)?$/)
      if !(address.nil?)
        biz_city = address.city
        biz_state = address.state
        biz_zipcode = address.postal_code
        biz_addr = address.to_s(:line1)
      end 
    end

    broker_company = BrokerCompany.where(license_id:biz_license_id).first
    if (broker_company.nil? &&  !biz_name.nil? && !biz_zipcode.nil? && !biz_state.nil?)
      broker_company = BrokerCompany.where(name:biz_name, state:biz_state, zipcode:biz_zipcode).first
      broker_company = BrokerCompany.new(:license_id => biz_license_id, :name => biz_name, :addr => biz_addr, :city => biz_city, :state => biz_state, :zipcode => biz_zipcode) if broker_company.nil? 
    end
    
    if (!broker_company.nil? )
#      print 'update broker:', broker_company, "\n"
      broker_company.country = "USA"
      broker_company.phone = broker_agent[6].nil? ? broker_company.phone : broker_agent[6]
      if (broker_company.license_id.nil? && !biz_license_id.nil?)
        broker_company.license_id = biz_license_id 
      end
      broker_company.save
    end  
         
    if (!broker_company.nil?)
      print 'create/update agent:', broker_agent[8], "\n"
      if (!broker_agent[18].nil? && broker_agent[18].match(/[-+]?[0-9]+/))
        biz_state = broker_company.state if biz_state.nil?
        agent = AgentExtention.where(license_id:broker_agent[18].lstrip.rstrip, license_state:biz_state).first
        agent = AgentExtention.new(:license_id => broker_agent[18].lstrip.rstrip, :license_state => biz_state) if agent.nil?    
        agent.first_name = broker_agent[8].nil? ? agent.first_name : broker_agent[8].lstrip.rstrip
        if (!broker_agent[8].eql?(broker_agent[9]))
          agent.middle_name = broker_agent[9].nil? ? agent.middle_name : broker_agent[9].lstrip.rstrip
        end
        agent.last_name = broker_agent[10].nil? ? agent.last_name : broker_agent[10].lstrip.rstrip
        agent.cn_name = broker_agent[11].nil? ? agent.cn_name : broker_agent[11].lstrip.rstrip
        agent.phone = broker_agent[12].nil? ? agent.phone : broker_agent[12].lstrip.rstrip
        agent.wechat = broker_agent[13].nil? ? agent.wechat : broker_agent[13].lstrip.rstrip
        agent.mail = broker_agent[14].nil? ? agent.mail : broker_agent[14].lstrip.rstrip
        agent.url = broker_agent[15].nil? ? agent.url : broker_agent[15].lstrip.rstrip
        agent.city_area = broker_agent[16].nil? ? agent.city_area : broker_agent[16].lstrip.rstrip 
        agent.license_issue = broker_agent[17].nil? ? agent.license_issue : Date.strptime(broker_agent[17].lstrip.rstrip, "%m/%d/%y")
        agent.license_type = broker_agent[19].nil? ? agent.license_type : broker_agent[19].lstrip.rstrip
        agent.license_expire = broker_agent[20].nil? ? agent_license_expire : Date.strptime(broker_agent[20].lstrip.rstrip, "%m/%d/%y")
        agent.description = broker_agent[21].nil? ? agent.description : broker_agent[21].lstrip.rstrip
        agent.photo_url = broker_agent[22].nil? ? agent.photo_url : broker_agent[22].lstrip.rstrip[10..-5]
        agent.city_list = broker_agent[23].nil? ? agent.city_list : broker_agent[23].lstrip.rstrip
        agent.district_list = broker_agent[24].nil? ? agent.district_list : broker_agent[24].lstrip.rstrip
        agent.mailing_address = broker_agent[25].nil? ? agent.source : broker_agent[25].lstrip.rstrip 
        agent.source = broker_agent[26].nil? ? agent.source : broker_agent[26].lstrip.rstrip 
        agent.source_id = broker_agent[27].nil? ? agent.source_id : broker_agent[27].lstrip.rstrip 
        agent.status = "pending" if  agent.status.nil?
        agent.broker_company_id = broker_company.id
        agent.save
      end 
    end     
  end
end
