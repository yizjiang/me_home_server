class Home < ActiveRecord::Base
  attr_accessible *column_names
  has_many :images
  has_many :home_school_assignments
  has_many :schools, through: :home_school_assignments

  has_many :favorite_homes, foreign_key: 'home_id'
  has_many :users, through: :favorite_homes

  def self.search(search)
    result = []
    if search.region != ''             #TODO make it smart
      search.region.split(',').each do |region|
        result.push(*where('(city LIKE ? or zipcode LIKE ?) and price < ? and price > ?', "%#{region}%", "%#{region}%", search.price_max, search.price_min))
      end
    else
      result.push(*where('price < ? and price > ?', search.price_max, search.price_min))
    end
    result
  end

  def assign_schools(schools, assigned, type)
    schools.each do |school|
      record = School.where(name: school[0], grade: school[2], school_type: type).first_or_create
      record.student_teacher_ratio= school[3]
      record.rating= school[4]
      record.save

      assignment = HomeSchoolAssignment.where(home_id: self.id, school_id: record.id).first_or_create
      assignment.update_attributes(distance: record[1], assigned: assigned)
    end
  end

  def assign_public_schools(schools)
   assign_schools(schools, true, 'public')
  end

  def build_image_group(images)
    images.split('<img src=')[1..-1].each do |image|
      image_url = "localhost:3032/#{image[1..-3]}"
      Image.where(image_url: image_url).first_or_create do |new_image|
       new_image.home_id = self.id
      end
    end
  end

end