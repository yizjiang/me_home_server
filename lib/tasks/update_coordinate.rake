# encoding: utf-8
namespace :homes do
  task :coordinate => :environment do
    Home.all.each do |home|
      address =  "#{home.addr1} #{home.addr2}, #{home.city}, #{home.state}, #{home.zipcode}"
      request = "https://dev.virtualearth.net/REST/v1/Locations/#{URI::encode(address)}?output=json&key=AjVrfYUU-6_5NnEHSjCxZ16XAJHyu0-J42p16WXCld6F52NujvxQ2iRV1X3UQeQs"
      response = Typhoeus.get(request)
      begin
        geo_point = JSON.parse(response.body)['resourceSets'][0]['resources'][0]['point']['coordinates'].join(',')
        home.update_attributes(geo_point: geo_point)
        p "Home #{home.id} updated"
      rescue
        p "Home #{home.id} error out"
      end
    end
  end
end
