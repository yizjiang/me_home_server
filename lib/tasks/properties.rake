namespace :csv do
  desc 'import xls from file'

  task :property => :environment do
    puts 'Enter csv file name under sample/data/'
    
    file = STDIN.gets.chomp
   # univ = CSV.read("./sample/data/#{file}.csv")
     univ = CSV.read("./sample/data/#{file}.csv", :encoding => 'windows-1251:utf-8')
    univ[1..-1].each_with_index do |row, index|
     

    query_condition = {source_id: row[0],
       costar_link: row[1],
    }
    
    property = Property.where(query_condition).first
    #print query_condition, ", ", property, "\n"    
    if (!property.nil?) 
        if (!row[25].nil? && !row[24].nil?)
	    geo = row[25] + "," + row[24]
	    p geo
        end
	
	b_r = row[17].nil? ? row[18]:row[17]
	p b_r
        c_id =  property.sale_property_id
        #print "c_id =", c_id, ", p_id", property.source_id, "\n" 
	commercial = Commercial.where(id:c_id).first
        #print "-----",  commercial, "\n"
         if (!commercial.nil?)
    	     commercial.update_attributes(submarket: row[8],
                                   market: row[9],
				   year_b_r: b_r,
				   geo_point: geo
	     )
           
            row[16] = row[16].delete(',') unless row[16].nil?
	    a_property = row[0..23]
	    a_property.insert(-1,geo)
	    a_property.insert(-1,commercial.id)
             #print "url=", url," index=", index, "\n"
            property = Property.update_full(a_property)
          end
     end
    end 
    p '---- done ---'
  end



  # add validation


end
