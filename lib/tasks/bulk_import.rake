namespace :csv do
  desc 'import xls from file'
  task :import => :environment do
    puts 'Enter csv file name under sample/data/'
    file = STDIN.gets.chomp
#    home = CSV.read("./sample/data/#{file}.csv", :encoding => 'windows-1251:utf-8')
    home = CSV.read("./sample/data/#{file}.csv")
    home[1..-1].each_with_index do |row, index|
      begin
        #row.each_with_index{|r, index| p "#{home[0][index]} : #{r}"}
        if ( !(row[7].nil? || row[7].empty? || row[5].nil? || row[17].nil? || row[25].nil? || row[25].empty?) && row[5] == 'CA')
          home_city = row[4].lstrip.rstrip 
          home_state = row[5].lstrip.rstrip
          home_zip = row[6].lstrip.rstrip
          home_county = row[7].lstrip.rstrip 
	  uniq_condition = {addr1: row[3].lstrip.rstrip,
                          city: home_city,
                          state: home_state,
                          zipcode: home_zip}
          home = Home.where(uniq_condition).first_or_create
          if (home.id < 4494)
	       print home.id, " ", home.price, " ", home.status, " ",  home.addr1, "\n"
          end
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

           home.build_image_group(row[25]) unless row[25].nil?

           assigned_schools = row[28] ? parse_wierd_input_to_array(row[28])[1..-1] : []  #remove header 
           elementary_schools = row[29] ?  parse_wierd_input_to_array(row[29])[1..-1] : [] 
           middle_schools =  row[30] ? parse_wierd_input_to_array(row[30])[1..-1]: [] 
           high_schools =  row[31] ? parse_wierd_input_to_array(row[31])[1..-1]: [] 
           #private_schools = row[32] ? parse_wierd_input_to_array(row[32])[1..-1]: [] 

          # import assigned school last, so it will not overwrite it.
          #home.import_public_record(row[0..2])
          home.import_public_record(row[0..2].concat([row[9]]).concat([row[24]]).concat([row[17]]))
          #home.other_schools(elementary_schools + middle_schools + high_schools, home_city, home_county, home_state)
          #home.assign_public_schools(assigned_schools, home_city, home_county, home_state)
          #home.assign_private_schools(private_schools)
  
          home_history = row[32] ? parse_wierd_input_to_array(row[32])[1..-1]: []
          home.import_history_record(home_history)
        else 
	 print "not import: ", index , "," , row[3], "\n"
	end

      rescue StandardError
        # p "error out for item #{index}"
	print "error out for item: ", index , "," , row[3], "\n"
      end
      # property_tax: 65
    end
  end

  task :college => :environment do
    puts 'Enter csv file name under sample/data/'
    
    file = STDIN.gets.chomp
    univ = CSV.read("./sample/data/#{file}.csv")
    univ[1..-1].each_with_index do |row, index|
      
      if (row[4] != nil && row[4].lstrip.rstrip.length > 2)
      	row[4] = state_code(row[4])
      end 
      if (row[10] != nil)
         row[10] << '/' unless row[10].end_with?('/')
         row[10].gsub!('://', '://www.') unless row[10].include?('www.')
      end 
  
      if (row[7] != nil && row[7].lstrip.rstrip != "PK" && row[7].lstrip.rstrip != "K" && row[7].lstrip.rstrip != "PK-K")
          a_school =School.importer(row)
	  if (a_school != nil)
	      a_school.import_image(row[9]) unless row[9].nil?
	  end
      end 
   #    a_school.import_image(row[9]) unless row[9].nil?
     end
    p '---- done ---'
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

  def state_code(state_name)
    states = {
      "Alabama" => "AL",
      "Alaska" => "AK",
      "Arizona" => "AZ",
      "Arkansas" => "AR",
      "California" => "CA",
      "Colorado" => "CO",
      "Connecticut" => "CT",
      "Delaware" => "DE",
      "District Of Columbia" => "DC",
      "Florida" => "FL",
      "Georgia" => "GA",
      "Hawaii" => "HI",
      "Idaho" => "ID",
      "Illinois" => "IL",
      "Indiana" => "IN",
      "Iowa" => "IA",
      "Kansas" => "KS",
      "Kentucky" => "KY",
      "Louisiana" => "LA",
      "Maine" => "ME",
      "Maryland" => "MD",
      "Massachusetts" => "MA",
      "Michigan" => "MI",
      "Minnesota" => "MN",
      "Mississippi" => "MS",
      "Missouri" => "MO",
      "Montana" => "MT",
      "Nebraska" => "NE",
      "Nevada" => "NV",
      "New Hampshire" => "NH",
      "New Jersey" => "NJ",
      "New Mexico" => "NM",
      "New York" => "NY",
      "North Carolina" => "NC",
      "North Dakota" => "ND",
      "Ohio" => "OH",
      "Oklahoma" => "OK",
      "Oregon" => "OR",
      "Pennsylvania" => "PA",
      "Rhode Island" => "RI",
      "South Carolina" => "SC",
      "South Dakota" => "SD",
      "Tennessee" => "TN",
      "Texas" => "TX",
      "Utah" => "UT",
      "Vermont" => "VT",
      "Virginia" => "VA",
      "Washington" => "WA",
      "West Virginia" => "WV",
      "Wisconsin" => "WI",
      "Wyoming" => "WY"
    }
     code = states[state_name]
  end   

end
