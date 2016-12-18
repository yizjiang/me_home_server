namespace :csv do
  desc 'import xls from file'

  task :commercial => :environment do
    puts 'Enter csv file name under sample/data/'
    
    file = STDIN.gets.chomp
    univ = CSV.read("./sample/data/#{file}.csv", :encoding => 'windows-1251:utf-8')
    #univ = CSV.read("./sample/data/#{file}.csv")
    univ[1..-1].each_with_index do |row, index|
      #p index
      # insert broker company
      c_name = row[23]
      if (!row[24].nil?)
         c_address_full = convert_to_array(row[24].lstrip.rstrip)
         if (c_address_full.length == 3)
	     c_addr1 = c_address_full[0]
             c_city = c_address_full[1]
             c_state_temp = c_address_full[2].lstrip.rstrip.split(" ")
             c_state = c_state_temp[0]
             c_zipcode = c_state_temp[1]
         elsif (c_address_full.length == 2)
             c_city = c_address_full[0]
             c_state_temp = c_address_full[1].lstrip.rstrip.split(" ")
             c_state = c_state_temp[0]
             c_zipcode = c_state_temp[1]
	 end
      end 
      c_phone = parse_input_phone(row[25].lstrip.rstrip) unless row[25].nil?
      c_web = row[26]
      #print c_name, ",",c_addr1, ",",c_city, ",", c_state, ",", c_zipcode, ",", c_phone, ",",c_web, "\n"
      company = BrokerCompany.import_one(c_name, c_addr1, c_city, c_state, c_zipcode, c_phone, c_web)
      
      if (!row[27].nil?)
      	 a_name = row[27].lstrip.rstrip.split(" ") unless row[27].nil?
      	 a_firstname = a_name[0]
      	 a_lastname = a_name[1]
      end 
      a_title = row[28]
      a_phone = parse_input_phone(row[29].lstrip.rstrip) unless row[29].nil?
      a_email = row[30]
      #print a_firstname,",", a_lastname, ",",a_title, ",",a_phone, ",", a_email, "\n"
      agent = AgentExtention.import_one(a_firstname, a_lastname,a_title,c_city,c_state, a_phone, a_email, company.id)
      s_addr = row[31]
      a_commercial = row[0..21]
      a_commercial.insert(-1,company.id)
      a_commercial.insert(-1,agent.id)
      on_market = days_before_now(row[9])
      p_ids = convert_to_array(row[13])
      p_urls = convert_to_array(row[14])
      type = convert_to_array(row[15])
      rating = convert_to_array(row[16])
      addr = convert_to_array(row[17])
      a_commercial[9] = on_market
      a_commercial[15] = type[0]
      a_commercial[16] = rating[0]
      
      a_commercial[17] = s_addr unless s_addr.nil?
      a_commercial[17] = addr[0] unless a_commercial[17].nil?
      #print "s_addr= ",a_commercial[17],"p_addr: ", addr[0], "\n"
      # print "check a_commercial:", a_commercial, "\n"
       commercial = Commercial.importer(a_commercial)
       print "index=", index, "c_id:",  commercial.id, "\n"

      # insert image
      #print "insert image: ", row[22], "\n"
      if (!commercial.nil? && !row[22].nil?)
	  CommercialImage.importer(row[22], commercial.id) 
      end
     
      #print " insert property ", "\n"
      city =  a_commercial[18]
      county = a_commercial[19]     
      zipcode = a_commercial[20]     
      state = a_commercial[21]     
      # insert property
      #p a_commercial[13]
      #p a_commercial[14]  
      index = 0;
      if (!commercial.nil?  && !p_ids.nil? && !p_urls.nil? )
          p_urls.each do |url|          
      	    #print "url=", url," index=", index, "\n"
            row = [p_ids[index], url, addr[index], city, county, state, zipcode, type[index],rating[index],commercial.id]	    
            property = Property.import_simple(row)
	    index = index + 1
          end  
      end	
      
    end 
    p '---- done ---'
  end



  # add validation

  
  def parse_input_phone(input)
    input.gsub!(',(', ' (')
    #p input
  end

  def convert_to_array(input)
    #input.split(",").map do |item|
    # p item
    #end
      return input.split(",")
  end

  def days_before_now(days)  # time is day
    past = Time.now - days.to_i * 24*3600
    return past
  end

end
