namespace :csv do
  desc 'import xls from file'
  task :import => :environment do
    home = CSV.read('./sample/data/san-mateo0729.csv')
    home[1..-1].each_with_index do |row, index|
      begin
      uniq_condition = {addr1: row[1],
                        city: row[2],
                        state: row[3],
                        zipcode: row[4]}
      home = Home.where(uniq_condition).first_or_create
      home.update_attributes(county: row[5],
                             last_refresh_at: time_before_now(row[6]),
                             link: row[8],
                             description: row[10],
                             bed_num: row[11],
                             bath_num: row[12],
                             indoor_size: row[13],
                             lot_size: row[14],
                             price: row[15].delete(','),
                             unit_price: row[16],
                             home_type: row[17],
                             year_built: row[18].to_i,
                             neighborhood: row[19],
                             stores: row[21],
                             status: row[22]
                             )

      home.build_image_group(row[9])
      assigned_schools = parse_wierd_input_to_array(row[55])[1..-1] #remove header
      home.assign_public_schools(assigned_schools)
      rescue StandardError
        p "error out for item #{index}"
      end
      #assiged_public_school: 55, public_school: 56, private_school: 59, property_tax: 61
    end
  end

  task :college => :environment do
    univ = CSV.read('./sample/college.csv')
    univ[1..-1].each_with_index do |row, index|
      School.importer(row)
    end

  end
  # add validation
  def parse_wierd_input_to_array(input)
    input.split("}").map do |item|
      item[2..-2].split(",\"").map do |item|
        item[0..-2]
      end
    end
  end

  def time_before_now(time)
    Time.now - time.to_i * 3600
  end

end
