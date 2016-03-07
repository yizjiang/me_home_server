# encoding: utf-8

class City < ActiveRecord::Base
  attr_accessible :PMI, :above_bachelor, :asian, :black, :caucasion, :county, :created_at, :crime, :hispanics, :income, :name, :population, :state_unemploy, :unemploy, :updated_at, :us_crime, :state

  def as_json
    result = super
    result[:population] = wrap_value(self.population)
    result[:income] = wrap_value(self.income)
    return result
  end

  def wrap_value(num)
    return "#{(num/10000).round(1)}万"
  end
end
