class School < ActiveRecord::Base
  include ActiveModel::Serialization
  attr_accessible *column_names
  has_many :home_school_assignments
  has_many :homes, through: :home_school_assignments
  has_one :address, foreign_key: 'entity_id'

  def attributes
    {name: nil, grade: nil, student_teacher_ratio: nil, rating: nil, school_type: nil,
     rank: nil, url: nil, female_pct: nil, admin_rate: nil, enrolled_student: nil,
     geo_point: nil}
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

  def as_json(options=nil)
    options ||= {}
    result = super(options)
    result[:name] = self.name
    result[:grade] = self.grade
    result[:student_teacher_ratio] = self.student_teacher_ratio
    result[:rating] = self.rating
    result[:school_type] = self.school_type
    result[:rank] = self.rank
    result[:url] = self.url
    result[:female_pct] = self.female_pct
    result[:admin_rate] = self.admin_rate
    result[:enrolled_student] = self.enrolled_student
    result[:geo_point] = self.geo_point
    # result[:assigned_school] = self.get_assigned_schools
    # result[:public_schools] = self.get_other_public_schools
    # result[:private_schools] = self.get_private_schools
    # result[:chinese_description] = self.home_cn.try(:description)
    # result[:short_desc] = self.home_cn.try(:short_desc)
    # result[:city_info] = City.find_by_name(self.city)
    # result[:public_record] = get_latest_record || {}
    # result[:monthly_rent] = self.cal_money
    # result[:property_tax] = wrap_money((self.price * PROPERTY_TAX).round)
    # result[:origin_price] = self.price
    # result[:colleges] = self.get_college
    result
  end

  def self.importer(school)    
    # this part for school from waijule
    zip_code = school[5].lstrip.rstrip.split("-")[0] unless school[5].nil?
   # print zip_code, "old one", school[5], "\n"
    if (school[0] != nil && school[1] != nil && school[2] != nil && school[3] != nil && school[4] != nil && school[5] != nil) 
      record = School.where(name:school[0].lstrip.rstrip, city:school[3].lstrip.rstrip, state:school[4].lstrip.rstrip,zipcode:zip_code).first
      record = School.where(name:school[0].lstrip.rstrip, addr1:school[2].lstrip.rstrip, city:school[3].lstrip.rstrip, state:school[4].lstrip.rstrip).first if record.nil?
      record = School.where(addr1:school[2].lstrip.rstrip, city:school[3].lstrip.rstrip, state:school[4].lstrip.rstrip, zipcode:zip_code).first if record.nil?
      if (record == nil && school[10] != nil)
        record = School.where(url:school[10].lstrip.rstrip, zipcode:zip_code, city:school[3].lstrip.rstrip, state:school[4].lstrip.rstrip).first
      end 
      if (record != nil)
        p school[4] 
      end 
     # record = School.new(:name => school[0].lstrip.rstrip, :zipcode => zip_code, :city => school[3].lstrip.rstrip, :state => school[4].lstrip.rstrip) if record.nil?
    end 


    record = School.where(name:school[0].lstrip.rstrip, zipcode:zip_code,  city:school[3].lstrip.rstrip, state:school[4].lstrip.rstrip, grade:school[7].lstrip.rstrip).first if (record.nil? && school[1].nil?)
    record = School.where(name:school[0].lstrip.rstrip, addr1:school[2].lstrip.rstrip, city:school[3].lstrip.rstrip, state:school[4].lstrip.rstrip).first if (record.nil? && school[1].nil? && !school[2].nil?)
    if (!record.nil? && !record.zipcode.nil? && !zip_code.nil? && !record.zipcode.eql?(zip_code))
      record.zipcode = zip_code
    end 
     

    # print "school old zipcode:", record.zipcode, " new zipcode:", zip_code, "\n" unless record.nil?
    if (record.nil? && school[1].nil?)
      record = School.where(name:school[0].lstrip.rstrip, city:school[3].lstrip.rstrip, state:school[4].lstrip.rstrip, grade:school[7].lstrip.rstrip).first
      record = nil if (!record.nil? && !record.zipcode.nil? && record.zipcode != zip_code)
      #print "reset to null", school[5], "\n" if record.nil? 
    end 
    #print "find school: ", school[0], ",", school[5], ",", school[2],"\n"  unless record.nil?
    record = School.new(:name => school[0].lstrip.rstrip, :zipcode => zip_code,  :city => school[3].lstrip.rstrip, :state => school[4].lstrip.rstrip, :grade => school[7].lstrip.rstrip) if (record.nil? && school[1].nil?)
        
    if (record != nil) 
      record.name = school[0].nil? ? record.name : school[0].lstrip.rstrip if record.name.nil?
      record.name_cn = school[1].nil? ? record.name_cn : school[1].lstrip.rstrip if record.name_cn.nil?           
      record.addr1   = school[2].nil? ? record.addr1 : school[2].lstrip.rstrip if record.addr1.nil?
      record.school_type = school[6].nil? ? record.school_type : school[6].lstrip.rstrip.capitalize if record.school_type.nil?
      record.grade = school[7].nil? ? record.grade : school[7].lstrip.rstrip if record.grade.nil?
      record.description = school[8].nil? ? record.description : school[8].lstrip.rstrip if record.description.nil?
      record.url = school[10].nil? ? record.url : school[10].lstrip.rstrip if record.url.nil?
      record.phone = school[11].nil? ? record.phone : school[11].lstrip.rstrip if record.phone.nil?
      record.mail = school[12].nil? ? record.mail : school[12].lstrip.rstrip if record.mail.nil?
      record.founded = school[13].nil? ? record.founded : school[13].lstrip.rstrip if record.founded.nil?
      record.rank= school[14] if record.rank.nil?
      record.student_teacher_ratio = school[15].nil? ? record.student_teacher_ratio : school[15].lstrip.rstrip if record.student_teacher_ratio.nil?
      record.female_pct = school[17] if record.female_pct.nil?
      record.religion = school[18].nil? ? record.religion : school[18].lstrip.rstrip if record.religion.nil?
      record.gender_type = school[19].nil? ? record.gender_type : school[19].lstrip.rstrip if record.gender_type.nil?
      record.boarding_pct = school[20] if record.boarding_pct.nil?
      record.admin_rate = school[21] if record.admin_rate.nil?
      record.fee = school[22] if record.fee.nil?
      record.fee ||= school[24] 
      record.county = school[25].nil? ? record.county : school[25].lstrip.rstrip if record.county.nil?
      record.enrolled_student = school[26].nil? ? record.enrolled_student : school[26].lstrip.rstrip if record.enrolled_student.nil?
      #p record.rating
      #p school[27]
      record.rating = school[27].nil? ? record.rating : school[27].lstrip.rstrip if record.rating.nil?
      #p record.enrolled_student
      record.save
    end 
    return record
    #    address = Address.where(addr1: school[1], addr2: nil, city: school[2], state: school[3], zipcode: school[4]).first_or_create
    #    address.entity_id = record.id
    #    address.save
  end
  
end
