class Home < ActiveRecord::Base
  attr_accessible *column_names
  has_many :images
  has_many :public_records

  has_many :home_school_assignments
  has_one :home_cn, foreign_key: 'id'

  has_many :schools, through: :home_school_assignments

  has_many :favorite_homes, foreign_key: 'home_id'
  has_many :users, through: :favorite_homes

  def self.search(searches, limit = nil, last_refresh = Time.at(-284061600))
    unless searches.is_a? Array
      searches = [searches]
    end
    result = []
    searches.each do |search|
      if(region = search.region)
        if(region.multibyte?)
          homes_cn = HomeCn.where('city LIKE ?', "%#{region}%")
          homes = where('id in (?) and last_refresh_at > ? and price < ? and price > ? and status = ? and bed_num > ? and indoor_size > ? and year_built > ? and home_type in (?)',
                        homes_cn.pluck(:id), last_refresh, search.price_max, search.price_min, 'Active', search.bed_num - 1, search.indoor_size, search.year_built, search.home_type).order('last_refresh_at DESC').includes(:home_cn, :schools, :home_school_assignments, :images).limit(limit)
        else
          homes = where('last_refresh_at > ? and (city LIKE ? or zipcode LIKE ?) and price < ? and price > ? and status = ? and bed_num > ? and indoor_size > ? and year_built > ? and home_type in (?)',
                        last_refresh, "%#{region}%", "%#{region}%", search.price_max, search.price_min, 'Active', search.bed_num - 1, search.indoor_size, search.year_built, search.home_type).order('last_refresh_at DESC').includes(:home_cn, :schools, :home_school_assignments, :images).limit(limit)
        end

        limit -= homes.count if limit
        result.push(*homes)
        if limit == 0
          break
        end
      else
        result.push(*where('last_refresh_at > ? and price < ? and price > ? and indoor_size > ? and year_built > ? and status = ?', last_refresh, search.price_max, search.price_min, search.indoor_size, search.year_built, 'Active').includes(:home_cn, :home_school_assignments, :schools, :images).order('last_refresh_at DESC').limit(limit))
      end
    end
    result
  end

  def get_assigned_schools
    school_ids = self.home_school_assignments.select{|hs|hs.assigned == true}.map(&:school_id)
    self.schools.select{|s| school_ids.include?(s.id)}
  end

  def get_private_schools
    school_ids = self.home_school_assignments.select{|hs|hs.assigned == false}.map(&:school_id)
    self.schools.select{|s| school_ids.include?(s.id) && s.school_type == 'private'}
  end

  def get_other_public_schools
    school_ids = self.home_school_assignments.select{|hs|hs.assigned == false}.map(&:school_id)
    self.schools.select{|s| school_ids.include?(s.id) && s.school_type == 'public'}
  end

  def as_json(options=nil)
    options ||= {}
    if options[:addr_only]
      options.merge!(only: [:id, :addr1, :city])
      result = super(options)
    else
      result = super(options)
      result[:images] = self.images
      result[:assigned_school] = self.get_assigned_schools
      result[:public_schools] = self.get_other_public_schools
      result[:private_schools] = self.get_private_schools
      result[:schools] = self.schools
      result[:chinese_description] = self.home_cn.try(:description)
      result[:short_desc] = self.home_cn.try(:short_desc)
      if home_cn = self.home_cn
        result[:indoor_size] = home_cn.indoor_size
        result[:lot_size] = home_cn.lot_size
        result[:short_desc] = home_cn.short_desc
        result[:price] = home_cn.price
        result[:unit_price] = home_cn.unit_price
      end
    end

    result
  end

  def assign_schools(schools, assigned)
    schools.each do |school|
      record = School.where(name: school[0], grade: school[2], school_type: school[6]).first_or_create
      record.student_teacher_ratio = school[3]
      record.rating = school[4].to_f
      record.parent_rating = school[5].to_f    
      record.save

      assignment = HomeSchoolAssignment.where(home_id: self.id, school_id: record.id).first_or_create
      assignment.update_attributes(distance: school[1], assigned: assigned)
 
    end
  end

  def assign_public_schools(schools)
   assign_schools(schools, true)
  end

  def assign_private_schools(schools)
    assign_schools(schools, false)
  end

  def other_schools(schools)
    assign_schools(schools, false)
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
