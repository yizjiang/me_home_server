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
     record = School.where(name: school[0], city:school[3], state:school[4], grade:school[7]).first_or_create
     record.name_cn = school[1]
     record.addr1   = school[2]
     record.zipcode = school[5]
     record.school_type = school[6]
     record.grade = school[7] 
     record.description = school[8]

      record.url = school[10]
      record.phone = school[11]
      record.mail = school[12]
      record.founded = school[13]
      record.rank= school[14]
      record.student_teacher_ratio = school[15]
      record.female_pct = school[17]
      record.religion = school[18]
      record.gender_type = school[19]
      record.boarding_pct = school[20]
      record.admin_rate = school[21]
      record.fee = school[22]
      record.fee ||= school[24]
      record.save
      return record
#    address = Address.where(addr1: school[1], addr2: nil, city: school[2], state: school[3], zipcode: school[4]).first_or_create
#    address.entity_id = record.id
#    address.save
  end

end
