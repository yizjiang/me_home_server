namespace :csv do
  desc 'import xls from file'
  task :import => :environment do
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
			       added_to_site: row[9],
                               redfin_link: row[10],
   			       realtor_link: row[11],
                               description: row[12],
                               bed_num: row[13],
                               bath_num: row[14],
                               indoor_size: row[15],
                               lot_size: row[16],
                               price: row[17].delete(','),
                               unit_price: row[18],
                               home_type: row[19],
                               year_built: row[20].to_i,
                               neighborhood: row[21],
			       home_style: row[22],
                               stores: row[23],
                               status: row[24],
			       listing_agent: row[26],
			       listed_by: row[27]
        )

        home.build_image_group(row[25])  #[66]

        assigned_schools = row[28] ? parse_wierd_input_to_array(row[28])[1..-1] : [] #remove header
        elementary_schools = row[29] ?  parse_wierd_input_to_array(row[29])[1..-1] : [] 
        middle_schools =  row[30] ? parse_wierd_input_to_array(row[30])[1..-1]: [] 
        high_schools =  row[31] ? parse_wierd_input_to_array(row[31])[1..-1]: [] 
        private_schools = row[32] ? parse_wierd_input_to_array(row[32])[1..-1]: [] 

        # import assigned school last, so it will not overwrite it.
        home.import_public_record(row[0..2])
        home.other_schools(elementary_schools + middle_schools + high_schools)
        home.assign_public_schools(assigned_schools)
        home.assign_private_schools(private_schools)

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
