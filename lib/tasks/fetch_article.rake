namespace :wechat do
  task :article_count => :environment do
    token = get_access_token(true)
    response = Typhoeus.get("https://api.weixin.qq.com/cgi-bin/material/get_materialcount?access_token=#{token}")
    p JSON.parse response.body
  end

  task :agent_articles => :environment do
    token = get_access_token(true)
    articles = article_list(token)['item']
    articles.each do |article|
      news = article['content']['news_item']
      news.each do |item|
        unless AgentArticle.where(title: item['title'], media_id: article['media_id']).present?
          AgentArticle.create(
            media_id: article['media_id'],
            title: item['title'],
            content: item['content'].gsub('data-src', 'src'),
            thumb_media_id: item['thumb_media_id'],
            url: item['url'],
            digest: item['digest'],
            author: item['author'],
            content_source_url: item['content_source_url']
          )
        end
      end
    end
  end

  task :copy_articles => :environment do
    token = get_access_token
    articles = article_list(token)['item']
    articles.each do |article|
      news = article['content']['news_item']
      news.each do |item|
        p item['title']
        unless Article.where(title: item['title'], media_id: article['media_id']).present?
          Article.create(
            media_id: article['media_id'],
            title: item['title'],
            content: item['content'].gsub('data-src', 'src'),
            thumb_media_id: item['thumb_media_id'],
            url: item['url'],
            digest: item['digest'],
            author: item['author'],
            content_source_url: item['content_source_url']
          )

          p 'converting...'
          item['thumb_media_id'] = convert_thumb_media_id(item['thumb_media_id'])
          media_id = publish_article(item, get_access_token(true))['media_id']
          p "done #{media_id}"
        end
      end
    end
  end

  def convert_thumb_media_id(media_id)
    url = "https://api.weixin.qq.com/cgi-bin/material/get_material?access_token=#{get_access_token}"
    response = Typhoeus.post("#{url}", body: {media_id: media_id}.to_json)
    file = "#{Rails.root}/tmp/tmp.png"
    File.open(file, 'wb') do |outfile|
      outfile.write(response.body)
    end
    token = get_access_token(true)
    url = "https://api.weixin.qq.com/cgi-bin/material/add_material?access_token=#{token}"
    response = Typhoeus.post(url,
                             headers: {'Content-Type' => 'multipart/form-data'},
                             body: {:media => File.open(file, 'r')})
    JSON.parse(response.body)['media_id']
  end

  def publish_article(item, token)
    body = {
      articles: [{
                   content: item['content'].gsub('data-src', 'src'),
                   url: item['url'],
                   thumb_media_id: item['thumb_media_id'],
                   show_cover_pic: 1,
                   title: item['title'],
                   digest: item['digest'],
                   author: item['author'],
                   content_source_url: item['content_source_url']
                 }

      ]
    }
    url = "https://api.weixin.qq.com/cgi-bin/material/add_news?access_token=#{token}"
    response = Typhoeus.post("#{url}", body: body.to_json)
    JSON.parse(response.body)
  end

  def get_access_token(agent_account = false)
    if agent_account
      client_id = 'wxa0c0023c75216f37'
      client_secret = '06b19a67b9f1c3369e6f0f255b5952e3'
    else
      client_id = 'wxd284e53ecd0e2b51'
      client_secret = 'a1fd7beec066019b1b9b28efcba1e610'
    end
    params = {grant_type: 'client_credential',
              appid: client_id,
              secret: client_secret}
    response = Typhoeus.get("https://api.weixin.qq.com/cgi-bin/token", params: params)
    JSON.parse(response.body)['access_token']
  end

  def article_list(token)
    url = "https://api.weixin.qq.com/cgi-bin/material/batchget_material?access_token=#{token}"
    body = {
      type: 'news',
      offset: 0,
      count: 20
    }

    response = Typhoeus.post("#{url}", body: body.to_json)
    JSON.parse(response.body)
  end

end
