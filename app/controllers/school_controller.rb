class SchoolController < ApplicationController
  def index
    @schools = School.joins(:address).where(grade: '13+')
  end

  def all_schools
    schools = School.where(grade: 'college')
    result = schools.each do |school|
      school.as_json
    end
    render json: result
  end
end