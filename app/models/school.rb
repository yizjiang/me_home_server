class School < ActiveRecord::Base
  include ActiveModel::Serialization
  attr_accessible *column_names
  has_many :home_school_assignments
  has_many :homes, through: :home_school_assignments
  has_one :address, foreign_key: 'entity_id'

  def attributes
    {name: nil, grade: nil, student_teacher_ratio: nil, rating: nil, school_type: nil}
  end

  def self.importer(school)
    record = School.where(name: school[0], grade: '13+').first_or_create
    record.rating= school[5]
    record.save

    address = Address.where(addr1: school[1], addr2: nil, city: school[2], state: school[3], zipcode: school[4]).first_or_create
    address.entity_id = record.id
    address.save
  end
end