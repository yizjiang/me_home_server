# encoding: utf-8

RENT_MAPPING = {19=>"nineteen",
  18=>"eighteen",
  17=>"seventeen",
  16=>"sixteen",
  15=>"fifteen",
  14=>"fourteen",
  13=>"thirteen",
  12=>"twelve",
  11 => "eleven",
  10 => "ten",
  9 => "nine",
  8 => "eight",
  7 => "seven",
  6 => "six",
  5 => "five",
  4 => "four",
  3 => "three",
  2 => "two",
  1 => "one"
}

PROPERTY_TAX = 0.012

class Home < ActiveRecord::Base
  OTHER_PROPERTY_TYPE = ["Residential Land", "Mobile Home", "Other", "-"]

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
        homes = []
        normal_type = search.home_type - OTHER_PROPERTY_TYPE
        other_type = search.home_type - normal_type

        if(region.multibyte?)
          homes_cn = HomeCn.where('city LIKE ?', "%#{region}%")

          if normal_type.length > 0
            homes += where('id in (?) and last_refresh_at > ? and price < ? and price > ? and status = ? and bed_num > ? and indoor_size > ? and year_built > ? and meejia_type in (?)',
                   homes_cn.pluck(:id), last_refresh, search.price_max, search.price_min, 'Active', search.bed_num - 1, search.indoor_size, search.year_built, normal_type).order('last_refresh_at DESC').includes(:home_cn, :schools, :home_school_assignments, :images).limit(limit)
          end

          if other_type.length > 0
            homes += where('id in (?) and last_refresh_at > ? and price < ? and price > ? and status = ? and meejia_type in (?)',
                           homes_cn.pluck(:id), last_refresh, search.price_max, search.price_min, 'Active', other_type).order('last_refresh_at DESC').includes(:home_cn, :schools, :home_school_assignments, :images).limit(limit)
          end

        else

          if normal_type.length > 0
            homes +=  where('last_refresh_at > ? and (city LIKE ? or zipcode LIKE ?) and price < ? and price > ? and status = ? and bed_num > ? and indoor_size > ? and year_built > ? and meejia_type in (?)',
                            last_refresh, "%#{region}%", "%#{region}%", search.price_max, search.price_min, 'Active', search.bed_num - 1, search.indoor_size, search.year_built, normal_type).order('last_refresh_at DESC').includes(:home_cn, :schools, :home_school_assignments, :images).limit(limit)
          end

          if other_type.length > 0
            homes +=  where('last_refresh_at > ? and (city LIKE ? or zipcode LIKE ?) and price < ? and price > ? and status = ? and meejia_type in (?)',
                            last_refresh, "%#{region}%", "%#{region}%", search.price_max, search.price_min, 'Active', other_type).order('last_refresh_at DESC').includes(:home_cn, :schools, :home_school_assignments, :images).limit(limit)
          end
        end

        limit -= homes.count if limit
        result.push(*homes)
        if limit == 0
          break
        end
      else
        result.push(*where('last_refresh_at > ? and price < ? and price > ? and indoor_size > ? and year_built > ? and status = ? and meejia_type in (?)', last_refresh, search.price_max, search.price_min, search.indoor_size, search.year_built, 'Active', search.home_type).includes(:home_cn, :home_school_assignments, :schools, :images).order('last_refresh_at DESC').limit(limit))
      end
    end
    result
  end

  def schools_with_distance(schools)
    School.find(schools.map(&:school_id)).map do |school|
      school.serializable_hash.merge(distance: schools.select{|s| s.school_id == school.id}.first.distance)
    end
  end

  def get_assigned_schools
    schools = self.home_school_assignments.select{|hs|hs.assigned == true}
    School.find(schools.map(&:school_id)).map do |school|
      school.serializable_hash.merge(distance: schools.select{|s| s.school_id == school.id}.first.distance)
    end
  end

  def get_private_schools
    schools = self.home_school_assignments.select{|hs|hs.assigned == false}
    School.where("id in (?) AND school_type = ?", schools.map(&:school_id), 'private').map do |school|
      school.serializable_hash.merge(distance: schools.select{|s| s.school_id == school.id}.first.distance)
    end

  end

  def get_other_public_schools
    schools = self.home_school_assignments.select{|hs|hs.assigned == false}
    School.where("id in (?) AND school_type = ?", schools.map(&:school_id), 'public').map do |school|
      school.serializable_hash.merge(distance: schools.select{|s| s.school_id == school.id}.first.distance)
    end
  end

  def as_json(options=nil)
    options ||= {}
    if options[:shorten]
      options.merge!(only: [:id, :addr1, :city, :bed_num, :bath_num, :geo_point])
      result = super(options)
      if options[:all_images]
        result[:images] =  self.images.map do |img|
          CDN_HOST + '/photos/' + img[:image_url]
        end
      else
        result[:images] =  [self.images.try(:first)]
      end

    else
      result = super(options)
      result[:images] = self.images
      result[:assigned_school] = self.get_assigned_schools
      result[:public_schools] = self.get_other_public_schools
      result[:private_schools] = self.get_private_schools
      result[:chinese_description] = self.home_cn.try(:description)
      result[:short_desc] = self.home_cn.try(:short_desc)
      result[:city_info] = City.find_by_name(self.city)
      result[:public_record] = get_latest_record || {}
      result[:monthly_rent] = self.cal_money
      result[:property_tax] = wrap_money((self.price * PROPERTY_TAX).round)
      result[:origin_price] = self.price
      result[:colleges] = self.get_college
      result[:listing_agent] = self.get_listing_agent
    end

    result[:home_type] = convert_home_type(self.meejia_type)
    result[:chinese_home_type] = convert_home_type_to_chinese(result[:home_type])

    if home_cn = self.home_cn
      result[:chinese_indoor_size] = home_cn.indoor_size
      result[:chinese_lot_size] = home_cn.lot_size
      result[:short_desc] = home_cn.short_desc
      result[:price] = home_cn.price
      result[:unit_price] = home_cn.unit_price
    end
    result
  end

  def get_listing_agent
    agent_info = {name: self.listing_agent}
    if self.listing_agent.to_i != 0
      agent = User.find(self.listing_agent.to_i)
      agent_info.merge!(id: agent.id, name: agent.agent_extention.cn_name, profile_image: agent.wechat_user.head_img_url)
    end
    agent_info
  end

  def convert_home_type_to_chinese(type)
    case type
      when 'single_family'
        '别墅'
      when 'condo'
        '公寓'
      when 'townhouse'
        '联排别墅'
      when 'business'
        '商用'
      when 'land'
        '土地'
      when 'farm'
        '农场'
      else
        '其他'
    end
  end

  def convert_home_type(meejia_type)
    home_type = %w(single_family multi_family condo townhouse business land farm other)

    if meejia_type == 'Single Family Home'
      'single_family'
    elsif ['Multi Family Home', 'Duplex', 'Triplex', 'Fourplex'].include?(meejia_type)
      'multi_family'
    elsif ['Apartment', 'Condominium'].include?(meejia_type)
       'condo'
    elsif meejia_type == 'Townhouse'
       'townhouse'
    elsif meejia_type == 'Mixed Use'
       'business'
    elsif ['Residential Land', 'Residential Lot', 'Land'].include?(meejia_type)
      'land'
    elsif ['Farms', 'Ranches'].include?(meejia_type)
      'farm'
    else
      'other'
    end
  end

  def get_college
    schools = School.where(grade: 'college', zipcode: (self.zipcode.to_i - 1000 .. self.zipcode.to_i + 1000))
                    .where('geo_point != -1')
    if self.geo_point.to_i != -1
      schools.to_a.sort!{|x, y| compare_distance(x.geo_point, y.geo_point)}.first(2)
    else
      schools.to_a.first(2)
    end
  end

  def compare_distance(geo_a, geo_b)
    dist1 = distance(self.geo_point.split(','), geo_a.split(','))
    dist2 = distance(self.geo_point.split(','), geo_b.split(','))
    dist1 <=> dist2
  end

  def distance loc1, loc2
    loc1 = loc1.map(&:to_f)
    loc2 = loc2.map(&:to_f)
    rad_per_deg = Math::PI/180  # PI / 180
    rkm = 6371                  # Earth radius in kilometers
    rm = rkm * 1000             # Radius in meters

    dlat_rad = (loc2[0]-loc1[0]) * rad_per_deg  # Delta, converted to rad
    dlon_rad = (loc2[1]-loc1[1]) * rad_per_deg

    lat1_rad, lon1_rad = loc1.map {|i| i * rad_per_deg }
    lat2_rad, lon2_rad = loc2.map {|i| i * rad_per_deg }

    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))

    rm * c # Delta in meters
  end


  def get_latest_record
    records = self.public_records
    index = -records.length
    record = records[index]
    return {} unless record
    record = record.as_json
    record['event'] = if record['event'].include?('Sold')
                       '售出'
                     else
                      '还未成交'
                     end

    return record
  end

  def wrap_money(num)
    if(num > 10000)
      num = "#{(num/10000).round(1)}万美元"
    else
      num = "#{(num/1000).round}千美元"
    end
    return num
  end

  def cal_money
    monthly_rent = ''
    if self.bed_num && self.bed_num != 0
      begin
        monthly_rent = (Rent.find_by_city(self.city).send("#{RENT_MAPPING[self.bed_num]}_bed".to_sym) * self.indoor_size.to_i).round
        return  wrap_money(monthly_rent)
      rescue
        return ''
      end
    end
    return monthly_rent
  end

 def alternate_name(name)
#   if !name.nil? && name.include("Incorporated")?
     a_name = name.sub!("Incorporated","Inc")  
 #  end
 end

  def assign_schools(schools, assigned, city, county, state)
    schools.each do |school|
      school_state = state
      scool_city = city
      tokens = school[7].split("/") unless school[7].nil?
      school_state = tokens[3] unless tokens.nil?
      school_city = tokens[4].sub!("-"," ") unless tokens.nil?
    #  print school[7], ",", school_city, ",", school_state, "\n" unless school[7].nil?
      if !(school[6].nil? || school[6].empty?) 
        school_type = school[6].lstrip.rstrip.capitalize
        #record = School.where(name: school[0].lstrip.rstrip, school_type: school_type, city:city, county:county, state:state, grade:school[2]).first_or_create
        record = School.where(name: school[0].lstrip.rstrip, school_type: school_type, city:school_city, county:county, state:school_state, grade:school[2]).first
        record = School.where(name: school[0].lstrip.rstrip, county:county, state:school_state, grade:school[2]).first if record.nil?
        record = School.where(name: school[0].lstrip.rstrip, county:county, state:school_state).first if record.nil?
        school_name = alternate_name(school[0].lstrip.rstrip)
        record = School.where(name: school_name, school_type: school_type, city:city, county:county, state:state, grade:school[2]).first if record.nil? && !school_name.nil?
        record = School.where(name: school_name, county:county, state:state, grade:school[2]).first  if record.nil? && !school_name.nil?
        record = School.where(name: school_name, county:county, state:state).first  if record.nil? && !school_name.nil?

        #print "no shcool find --", city, ": ", school[0], "\n"  if record.nil?
        
        record = School.new(:name => school[0].lstrip.rstrip, :school_type => school_type, :city => city, :county => county, :state => state, :grade => school[2]) if record.nil?
       
        if !(record.nil?)
          record.school_type = school_type;
          record.grade = school[2] if record.grade.nil?
          record.student_teacher_ratio = school[3] if record.student_teacher_ratio.nil?
          record.rating = school[4].to_f if record.rating.nil?
          record.parent_rating = school[5].to_f  if record.parent_rating.nil?
          record.school_type = school_type if record.school_type.nil?
          record.save
          
          assignment = HomeSchoolAssignment.where(home_id: self.id, school_id: record.id).first_or_create
          assignment.update_attributes(distance: school[1], assigned: assigned)
        end 
      end 
    end
  end

  def assign_public_schools(schools, city, county, state)
   assign_schools(schools, true, city, county, state)
  end

  def assign_private_schools(schools, city, county, state)
    assign_schools(schools, false, city, county, state)
  end

  def other_schools(schools, city, county, state)
    assign_schools(schools, false, city, county, state)
  end

  def build_image_group(images)
    images.split('<img src=')[1..-1].each do |image|
     image_url = "/homes/#{image[1..-3]}"
       new_image = Image.where(image_url: image_url).first_or_create 
       if (new_image.home_id.nil?)
         new_image.home_id = self.id 
         new_image.save
       elsif (new_image.home_id != self.id)
         new_image = Image.where(image_url: image_url, home_id: self.id).first_or_create 
         new_image.save
       end
       
       # Image.where(image_url: image_url).first_or_create do |new_image|
       #   new_image.home_id = self.id
       #   p new_image
       # end
     end
  end

  
  def import_public_record(record)
    source = record[0].lstrip.rstrip unless record[0].nil?
    property_id = record[1].lstrip.rstrip unless record[1].nil?
    n_event = record[4].lstrip.rstrip unless record[4].nil?
    o_event = 'Active'
    history_record =  PublicRecord.where(event: o_event, home_id: self.id).first 
    o_event = 'Active-REO'
    history_record =  PublicRecord.where(event: o_event, home_id: self.id).first if history_record.nil?
    o_event = 'Active-Short Sale'
    history_record =  PublicRecord.where(event: o_event, home_id: self.id).first if history_record.nil?
    o_event = 'Price Change'
    history_record =  PublicRecord.where(event: o_event, home_id: self.id).first if history_record.nil?
    o_event = 'Price Change-REO'
    history_record =  PublicRecord.where(event: o_event, home_id: self.id).first if history_record.nil?
    o_event = 'Back On Market'
    history_record =  PublicRecord.where(event: o_event, home_id: self.id).first if history_record.nil?
  
   if (history_record.nil? && !property_id.nil? && !source.nil?)
      history_record =  PublicRecord.where(source: source, property_id: property_id, home_id: self.id, event:n_event).first
      if (history_record.nil?)
       # p "new row will be created or find"
        history_record =  PublicRecord.where(source: source, property_id: property_id, home_id: self.id).first_or_create
        history_record.file_id = record[2].lstrip.rstrip unless record[2].nil?
      end 
    end

    if (!history_record.nil?)
      history_record.record_date = record[3] unless record[3].nil?
      history_record.event = record[4].lstrip.rstrip unless record[4].nil?
      history_record.price = record[5].delete('$').delete(',') unless record[5].nil?
      history_record.save
    else
      p record
      p self.id
    end
    
  end

 def import_history_record(records)
    records.each do |record|
       if record[3].include? 'Sold'
          history_record =  PublicRecord.where(source: record[0], property_id: record[1],home_id: self.id).first_or_create
          history_record.record_date = record[2]
          history_record.event = record[3]
          history_record.price = record[4].delete('$').delete(',')
          history_record.save
          return
       end
    end
  end


end
