class SchoolController < ApplicationController
  def index
    @schools = School.joins(:address).where(grade: '13+')
  end
end