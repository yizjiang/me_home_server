class School < ActiveRecord::Base
  include ActiveModel::Serialization
  attr_accessible *column_names
  has_many :home_school_assignments
  has_many :homes, through: :home_school_assignments
  has_one :address, foreign_key: 'entity_id'

  def attributes
    {name: nil, grade: nil, student_teacher_ratio: nil, rating: nil, school_type: nil}
  end


  def import_image(images)
      if (!images.nil? && !images.empty?)
         images.split('<img src=')[1..-1].each do |image|  
             image_url = image[1..-4].lstrip.rstrip.chomp('"')
             #p image_url
             SchoolImage.where(image_url: image_url).first_or_create do |new_image| 
                new_image.school_id = self.id    
             end
         end 
      end    
  end


  def self.importer(school)
      record = School.where(name: school[0].lstrip.rstrip, city:school[3].lstrip.rstrip, state:school[4].lstrip.rstrip, grade:school[7].lstrip.rstrip).first_or_create
      record.name_cn = school[1].nil? ? nil : school[1].lstrip.rstrip
      record.addr1   = school[2].nil? ? nil : school[2].lstrip.rstrip
      record.zipcode = school[5]
      record.school_type = school[6].nil? ? nil : school[6].lstrip.rstrip.capitalize
      record.grade = school[7].nil? ? nil : school[7].lstrip.rstrip
      record.description = school[8].nil? ? nil : school[8].lstrip.rstrip
      record.url = school[10].nil? ? nil : school[10].lstrip.rstrip
      record.phone = school[11].nil? ? nil : school[11].lstrip.rstrip
      record.mail = school[12].nil? ? nil : school[12].lstrip.rstrip
      record.founded = school[13].nil? ? nil : school[13].lstrip.rstrip
      record.rank= school[14]
      record.student_teacher_ratio = school[15].nil? ? nil : school[15].lstrip.rstrip
      record.female_pct = school[17]
      record.religion = school[18].nil? ? nil : school[18].lstrip.rstrip
      record.gender_type = school[19].nil? ? nil : school[19].lstrip.rstrip
      record.boarding_pct = school[20]
      record.admin_rate = school[21]
      record.fee = school[22]
      record.fee ||= school[24]
      record.county = school[25].nil? ? nil : school[25].lstrip.rstrip
      record.county = school[25].nil? ? nil : school[25].lstrip.rstrip
      record.enrolled_student = school[26].nil? ? nil : school[26].lstrip.rstrip
      #p record.enrolled_student
      record.save
      return record
#    address = Address.where(addr1: school[1], addr2: nil, city: school[2], state: school[3], zipcode: school[4]).first_or_create
#    address.entity_id = record.id
#    address.save
  end

end
