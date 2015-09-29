class Home < ActiveRecord::Base
  attr_accessible *column_names
  has_many :images
  has_many :public_records

  has_many :home_school_assignments

  has_many :schools, through: :home_school_assignments do
    def assigned
      where("home_school_assignments.assigned = ?", true)
    end
    def other_public
      where("home_school_assignments.assigned = ? && school_type = ?", false, 'public')
    end
    def private
      where("home_school_assignments.assigned = ? && school_type = ?", false, 'private')
    end
  end

  has_many :favorite_homes, foreign_key: 'home_id'
  has_many :users, through: :favorite_homes

  def self.search(searches)
    unless searches.is_a? Array
      searches = [searches]
    end

    result = []
    searches.each do |search|
      if(region = search.region)
        result.push(*where('(city LIKE ? or zipcode LIKE ?) and price < ? and price > ? and status = ?', "%#{region}%", "%#{region}%", search.price_max, search.price_min, 'Active'))
      else
        result.push(*where('price < ? and price > ? and status = ?', search.price_max, search.price_min, 'Active'))
      end
    end
    result
  end

  def as_json
    result = super
    result[:assigned_school] = self.schools.assigned
    result[:public_schools] = self.schools.other_public
    result[:private_schools] = self.schools.private
    result
  end

  def assign_schools(schools, assigned, type)
    schools.each do |school|
      record = School.where(name: school[0], grade: school[2], school_type: type).first_or_create
      record.student_teacher_ratio= school[3]
      record.rating= school[4]
      record.save

      if assigned
        assignment = HomeSchoolAssignment.where(home_id: self.id, school_id: record.id).first_or_create
        assignment.update_attributes(distance: record[1], assigned: assigned)
      end
    end
  end

  def assign_public_schools(schools)
    assign_schools(schools, true, 'public')
  end

  def assign_private_schools(schools)
    assign_schools(schools, false, 'private')
  end

  def other_public_schools(schools)
    assign_schools(schools, false, 'public')
  end

  def build_image_group(images)
    images.split('<img src=')[1..-1].each do |image|
      image_url = "/homes/#{image[1..-3]}"
      Image.where(image_url: image_url).first_or_create do |new_image|
       new_image.home_id = self.id
      end
    end
  end

  def import_public_record(record)
    PublicRecord.where(source: record[0], property_id: record[1], file_id: record[2]).first_or_create do |pr|
      pr.home_id = self.id
    end
  end
end