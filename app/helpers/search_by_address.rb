module SearchByAddress
  extend ActiveSupport::Concern

  def search_by_address(addr)
    #addr_list = addr.split(' ')
    #addr_list = addr.join(',').split(',').map{|str| str.capitalize}
    addr_list = addr.split(',').map{|str| str.capitalize}
    result = ancestors.first.where('(addr1 LIKE ? and city LIKE ?) and status = ?', "%#{addr_list.first}%", "%#{addr_list.last}%", 'Active')

    if addr_list.count > 1
      result = result.select {|entity| entity.addr1.downcase.include?(addr_list[0].downcase)}
    end
    result
  end
end