namespace :csv do
  desc 'import xls from file'
  task :status => :environment do
    puts 'Enter csv file name under sample/data/'
    file = STDIN.gets.chomp
#    home = CSV.read("./sample/data/#{file}.csv", :encoding => 'windows-1251:utf-8')
    home = CSV.read("./sample/data/#{file}.csv")
    pb_count = 0
    ia_count = 0
    u_count = 0
    home[1..-1].each_with_index do |row, index|
      begin
        home_status = row[24].lstrip.rstrip 
	#row.each_with_index{|r, index| p "#{home[0][index]} : #{r}"}
        if ( !(row[4].nil? || row[4].empty? || row[5].nil? ) && (row[5] == 'CA' || row[5] == 'NY')  && !home_status.starts_with?('Active'))
	  home_city = row[4].lstrip.rstrip 
          home_state = row[5].lstrip.rstrip
          home_zip = row[6].lstrip.rstrip
          # home_county = row[7].lstrip.rstrip
          if (home_status.starts_with?('Price') || home_status.starts_with?('Back'))
	    home_status = 'Active' 
            pb_count = pb_count+1
	  else
	    home_status = 'Inactive'
	    row[24] = home_status + "-"+row[24] if !row[24].start_with?('Inactive')
            ia_count = ia_count+1
          end 

	  if (! (row[10].nil? || row[10].empty?))
              home = Home.where(city:home_city, state:home_state, redfin_link:row[10]).first 
              home = Home.where(state:home_state, redfin_link:row[10]).first if home.nil?
	      home.zipcode = home_zip unless home.nil? 
	  end

	  if (! (row[11].nil? || row[11].empty?))
              home = Home.where(city:home_city, state:home_state, realtor_link:row[11]).first 
              home = Home.where(state:home_state, redfin_link:row[11]).first if home.nil?
	      home.zipcode = home_zip unless home.nil? 
	  end

	  if (!home.nil?)
	      u_count = u_count+1
	      #print "find ", index , "," , row[3], ", city:", home_city, ", zip:", home_zip, ", state", home_state,  "\n"	  
              update_date =  time_before_now(row[8])
              home_price = row[17].delete(',') unless row[17].nil? 
	      if (home.status.eql?("Inactive"))
                print "it was inactive", home.addr1, ", new status=", home_status, "\n"
	      end 	 
	      home.update_attributes(
			  #     county: home_county,
                               last_refresh_at: update_date,
			   #    added_to_site: row[9],
                           #    redfin_link: row[10],
   			   #    realtor_link: row[11],
                           #    description: row[12],
                           #    bed_num: row[13],
                           #    bath_num: row[14],
                           #    indoor_size: row[15],
                           #    lot_size: row[16],
			       price: home_price,
                               unit_price: row[18],
                           #    home_type: row[19],
                           #    year_built: row[20].to_i,
                           #    neighborhood: row[21],
			   #    home_style: row[22],
                           #    stores: row[23],
                               status: home_status
			   #    listing_agent: row[26],
			   #    listed_by: row[27]
              )
	      home.import_public_record(row[0..2].concat([update_date]).concat([row[24]]).concat([row[17]])) 
              # home_history = row[32] ? parse_wierd_input_to_array(row[32])[1..-1]: []
              # home.import_history_record(home_history)
            else 
              print "not find for update: ", index , "," , row[3], ", city:", home_city, ", zip:", home_zip, ", state", home_state,  "\n"
            end
        else 
              print "no update: ", index , "," , row[3], ", city:", home_city, ", zip:", home_zip, ", state", home_state,  "\n"
        end
      rescue StandardError
        #p "error out for item #{index}"
     	print "error out for item: ", index , "," , row[3], "\n"
      end
      # property_tax: 65
    end
      print "pb=",  pb_count, ", ia_count=", ia_count, ", u_count=", u_count, "\n"
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
