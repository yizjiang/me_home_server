namespace :csv do
  desc 'import xls from file'
  task :update => :environment do
    puts 'Enter csv file name under sample/data/'
    file = STDIN.gets.chomp
    home = CSV.read("./sample/data/#{file}.csv", :encoding => 'windows-1251:utf-8')
    home[1..-1].each_with_index do |row, index|
      begin
        #row.each_with_index{|r, index| p "#{home[0][index]} : #{r}"}
        uniq_condition = {addr1: row[3],
                          city: row[4],
                          state: row[5],
                          zipcode: row[6]}
        home = Home.where(uniq_condition).first_or_create
        home.update_attributes(county: row[7],
                               last_refresh_at: time_before_now(row[8]),
                               link: row[10],
                               description: row[11],
                               bed_num: row[12],
                               bath_num: row[13],
                               indoor_size: row[14],
                               lot_size: row[15],
                               price: row[16].delete(','),
                               unit_price: row[17],
                               home_type: row[18],
                               year_built: row[19].to_i,
                               neighborhood: row[20],
                               stores: row[22],
                               status: row[23]
        )

#      home.build_image_group(row[66])
#      assigned_schools = row[59] ? parse_wierd_input_to_array(row[59])[1..-1] : [] #remove header
#      public_elementary =  parse_wierd_input_to_array(row[60])[1..-1]
#      public_middle =  parse_wierd_input_to_array(row[61])[1..-1]
#      public_high =  parse_wierd_input_to_array(row[62])[1..-1]
#      private_schools =  parse_wierd_input_to_array(row[63])[1..-1]

#      home.import_public_record(row[0..2])
#      home.assign_public_schools(assigned_schools)
#      home.other_public_schools(public_elementary + public_middle + public_high)
#      home.assign_private_schools(private_schools)

      rescue StandardError
        p "error out for item #{index}"
      end
      # property_tax: 65
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
        item.delete('""').delete('\"')
      end
    end
  end

  def time_before_now(time)  # time is hour
    Time.now - time.to_i * 3600
  end

end