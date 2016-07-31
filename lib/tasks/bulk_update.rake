namespace :csv do
  desc 'import xls from file'
  task :update => :environment do
    puts 'Enter csv file name under sample/data/'
    file = STDIN.gets.chomp
#    home = CSV.read("./sample/data/#{file}.csv", :encoding => 'windows-1251:utf-8')
    home = CSV.read("./sample/data/#{file}.csv")
    home[1..-1].each_with_index do |row, index|
      begin
        #row.each_with_index{|r, index| p "#{home[0][index]} : #{r}"}
        if (row[25].nil? || row[25].empty?)
          row[25] = row[37]
          if (!row[25].nil? &&	row[25].end_with?(".jpg"))
	     row[25] = row[25] + "\">" 
	  end 
          print "no photo: ", row[25] , "," , row[37], "\n"
        end
        if ((row[18].nil? || row[18].empty?) && !row[15].nil? && !row[17].nil?)
	    print "no unit price: ", row[3], ", price: ", row[17], ", house_size:", row[15], "\n"
            row[18] = (row[17].to_f / row[15].to_f).round
            print "unit price:", row[18], "\n"
        end

	#addr, state, zip, county  price (17), image
        if ( !(row[3].nil? || row[3].empty? || row[5].nil? || row[5].empty? || row[6].nil? || row[6].empty? || row[7].nil? || row[7].empty? || row[17].nil? || row[25].nil? || row[25].empty?) && (row[5] == 'CA' || row[5] == 'NY'))
          home_city = row[4].lstrip.rstrip 
          home_state = row[5].lstrip.rstrip
          home_zip = row[6].lstrip.rstrip
          home_county = row[7].lstrip.rstrip 
          if (home_city.eql?('Stanford') && home_state.eql?('CA') && home_county.eql?('Santa Clara'))
             home_city = 'Palo Alto'
          end
	  uniq_condition = {addr1: row[3].lstrip.rstrip,
                          city: home_city,
                          state: home_state,
                          zipcode: home_zip}
          home = Home.where(uniq_condition).first_or_create
          
          home.update_attributes(county: home_county,
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

          #home.build_image_group(row[25])  #[66]
           home.import_public_record(row[0..2].concat([row[9]]).concat([row[24]]).concat([row[17]]))
           home_history = row[32] ? parse_wierd_input_to_array(row[32])[1..-1]: []
           home.import_history_record(home_history)
 
           assigned_schools = row[28] ? parse_wierd_input_to_array(row[28])[1..-1] : [] #remove header
           elementary_schools = row[29] ?  parse_wierd_input_to_array(row[29])[1..-1] : [] 
           middle_schools =  row[30] ? parse_wierd_input_to_array(row[30])[1..-1]: [] 
           high_schools =  row[31] ? parse_wierd_input_to_array(row[31])[1..-1]: [] 
           private_schools = row[38] ? parse_wierd_input_to_array(row[38])[1..-1]: [] 
           # import assigned school last, so it will not overwrite it.
           home.other_schools(elementary_schools + middle_schools + high_schools + private_schools, home_city, home_county, home_state)
          home.assign_public_schools(assigned_schools, home_city, home_county, home_state)
          #home.assign_private_schools(private_schools)
       else
          print "not import: ", index , "," , row[3], "," ,row[5],",", row[6],",", row[7], "\n"
      
       end
 
      rescue StandardError
        #p "error out for item #{index}"
     	print "error out for item: ", index , "," , row[3], "\n"
      end
      # property_tax: 65
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
