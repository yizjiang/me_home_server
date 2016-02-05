class TicketGenerator
  def self.encrypt_uid(uid)       #TODO
    uid = (uid + 32) * 7
    return "74651#{uid}2329"
  end

  def self.decrypt_uid(ticket)
    uid = ticket[5..-5]
    uid = (uid.to_i / 7) - 32
    return uid
  end
end