class WechatController < ApplicationController
  def auth
    render text: params['echostr']
  end

  def message
    region = params['xml']['Content']
    search = Search.new(regionValue: region)
    homes = Home.search(search, 10)

    items = build_response_items(homes)
    response = multi_reply({from_username: params['xml']['FromUserName'],to_username: params['xml']['ToUserName'], items: items})
    p response
    render xml: response
  end

  def test
    response = multi_reply({from_username: 1234,to_username: 5678, items: [{title: 'house1', body: 'nice home',
                                                                            pic_url: 'http://www.zillowstatic.com/static-homepage/7512d57/static-homepage/images/backgrounds/1500x675_white_home.jpg',
                                                                            url: 'www.google.com'},
                                                                           {title: 'house2', body: 'bay area',
                                                                             pic_url: 'http://cdn.freshome.com/wp-content/uploads/2013/08/selling-your-home-cedar-shingle-home.jpg',
                                                                             url: 'www.google.com'}]})
    render xml: response
  end

  private

  def build_response_items(homes)
    homes.map do |home|
      {title: "#{home.bed_num} Beds #{home.home_type} at #{home.addr1}",
      body: 'nice home',
      pic_url: "http://81703363.ngrok.io/#{home.images.first.try(:image_url) || 'default.jpeg'}",
      url: home.link}
    end
  end

  def multi_reply(msg_hash)
    data = msg_hash
    file_content = File.open(File.expand_path("./app/helpers/response.xml.erb"), "r").read
    ERB.new(file_content).result(binding)
  end

  def auto_reply(msg_hash)
    XmlResp.new.build(ToUserName: msg_hash[:from_username],
                      FromUserName: msg_hash[:to_username],
                      CreateTime: Time.now.to_i,
                      MsgType: 'news',
                      ArticleCount: 1,
                      Articles:{
                        item: {
                          Title: 'Housing',
                          Description:  "Hello, your msg is #{msg_hash[:body]}\n",
                          PicUrl: 'https://mycampus.lipscomb.edu/image/image_gallery?uuid=030cdc81-2ecd-4fab-b2d9-49fc0b4b04a4&groupId=208453&t=1405003877728',
                          Url: 'http://www.usreclub.com:3001/#/'
                        }
                      }
    )
  end

end