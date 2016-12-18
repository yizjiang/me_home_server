class BrokerCompany < ActiveRecord::Base
  attr_accessible :addr, :city, :country, :name, :phone, :state, :zipcode

  def self.import_one(name, addr, city, state, zipcode, phone, web)
    uniq_condition =
      {
      name: name,
      addr: addr,
      city: city,
      state: state,
      zipcode: zipcode,
      country: 'USA'
    }

    company = BrokerCompany.where(uniq_condition).first_or_create
    company.update_attributes(phone: phone, web: web)
    return company
  end



end
