namespace :csv do
  desc 'import xls from file'
  task :status => :environment do
    puts 'Enter csv file name under sample/data/'
    file = STDIN.gets.chomp
#    home = CSV.read("./sample/data/#{file}.csv", :encoding => 'windows-1251:utf-8')
    home = CSV.read("./sample/data/#{file}.csv")
    home[1..-1].each_with_index do |row, index|
      begin
        home_status = row[24].lstrip.rstrip 
	#row.each_with_index{|r, index| p "#{home[0][index]} : #{r}"}
        if ( !(row[7].nil? || row[7].empty? || row[5].nil? ) && row[5] == 'CA'  && !home_status.starts_with?('Active'))
          home_city = row[4].lstrip.rstrip 
          home_state = row[5].lstrip.rstrip
          home_zip = row[6].lstrip.rstrip
          # home_county = row[7].lstrip.rstrip
          if (home_status.starts_with?('Price') || home_status.starts_with?('Back'))
	    home_status = 'Active' 
	  else
	    home_status = 'Inactive'
          end 

	  uniq_condition = {addr1: row[3].lstrip.rstrip,
                          city: home_city,
                          state: home_state,
                          zipcode: home_zip}
          home = Home.where(uniq_condition).first
	  if (!home.nil?)	  
              update_date =  time_before_now(row[8])
              home_price = row[17].delete(',') unless row[17].nil? 
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
              #p home.status
	      home.import_public_record(row[0..2].concat([update_date]).concat([row[24]]).concat([row[17]])) 
              # home_history = row[32] ? parse_wierd_input_to_array(row[32])[1..-1]: []
              # home.import_history_record(home_history)
            end
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