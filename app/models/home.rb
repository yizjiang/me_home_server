class Home < ActiveRecord::Base
  attr_accessible *column_names
  has_many :images
  has_many :public_records

  has_many :home_school_assignments
  has_one :home_cn, foreign_key: 'id'

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

  def self.search(searches, limit = nil, last_refresh = Time.at(-284061600))
    unless searches.is_a? Array
      searches = [searches]
    end
    result = []
    searches.each do |search|
      if(region = search.region)
        if(region.multibyte?)
          homes_cn = HomeCn.where('city LIKE ?', "%#{region}%")
          homes = where('id in (?) and last_refresh_at > ? and price < ? and price > ? and status = ? and bed_num > ? and home_type in (?)',
                        homes_cn.pluck(:id), last_refresh, search.price_max, search.price_min, 'Active', search.bed_num - 1, search.home_type).order('last_refresh_at DESC').includes(:home_cn, :schools, :images).limit(limit)
        else
          homes = where('last_refresh_at > ? and (city LIKE ? or zipcode LIKE ?) and price < ? and price > ? and status = ? and bed_num > ? and home_type in (?)',
                        last_refresh, "%#{region}%", "%#{region}%", search.price_max, search.price_min, 'Active', search.bed_num - 1, search.home_type).order('last_refresh_at DESC').includes(:home_cn, :schools, :images).limit(limit)
        end

        limit -= homes.count if limit
        result.push(*homes)
        if limit == 0
          break
        end
      else
        result.push(*where('last_refresh_at > ? and price < ? and price > ? and status = ?', last_refresh, search.price_max, search.price_min, 'Active').includes(:home_cn, :schools, :images).order('last_refresh_at DESC').limit(limit))
      end
    end
    result
  end

  def as_json(options=nil)
    options ||= {}
    if options[:addr_only]
      options.merge!(only: [:id, :addr1, :city])
      result = super(options)
    else
      result = super(options)
      result[:images] = self.images
      #TODO more efficient query
      result[:assigned_school] = self.schools.assigned
      result[:public_schools] = self.schools.other_public
      result[:private_schools] = self.schools.private
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