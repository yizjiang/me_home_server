namespace :csv do
  desc 'import xls from file'

  task :agent => :environment do
    puts 'Enter csv file name under sample/data/'
    
    file = STDIN.gets.chomp
    univ = CSV.read("./sample/data/#{file}.csv")
    univ[1..-1].each_with_index do |row, index|
      if row[28].eql?("BROKER")
         row[7] = row[29] unless row[29].nil?
         row[0] = row[30] unless row[30].nil?
      end 
      if (row[7] != nil || row[0]!= nil)
          agent =AgentExtention.importer(row)
      end 
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

end
