class BrokerCompany < ActiveRecord::Base
  attr_accessible :addr, :city, :country, :name, :phone, :state, :zipcode
end
