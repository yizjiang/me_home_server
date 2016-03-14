# encoding: utf-8

class PublicRecord < ActiveRecord::Base
  belongs_to :home
  attr_accessible *column_names

  def as_json(options=nil)
    result = super
    result['price'] = wrap_value(self.price)
    return result
  end

  def wrap_value(num)
    return "#{(num/10000).round(1)}万"
  end
end