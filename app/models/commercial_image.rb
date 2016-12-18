class CommercialImage < ActiveRecord::Base
  attr_accessible :commercial_id, :created_at, :image_url, :updated_at
  def self.importer(images, commercial_id)
    images.split('<img src=')[1..-1].each do |image|
      image_url = image[1..-4].lstrip.rstrip.chomp('"')
      #p image_url
      CommercialImage.where(image_url: image_url, commercial_id:commercial_id).first_or_create
    end
    
  end

end 
