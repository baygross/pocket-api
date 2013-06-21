require 'open-uri'
require 'net/http'

module SyncAPI

  # grabs RSS feed from pocket and strips to list of links
  def self.grabRSS( user_name)
    url = 'http://getpocket.com/users/' + user_name + '/feed/all'
    uri = URI(url)
    resp = Net::HTTP.get(uri)
    links = resp.scan( /<guid>([^<]*)<\/guid>/ ).flatten
    return links
  end

  # given an array of urls, returns an array of article data from diffbot
  def self.loadLinks( urls, diffbot_token )
    articles = []
    
    # parse each url with DiffBot
    urls.each do |url|
      puts 'now processing: ' + url
      content = SyncAPI.grabJSON( url, diffbot_token ) 
      content = SyncAPI.parseJSON( content, source )
      articles << content if content
    end
    
    return articles
  end

  # hit the diffbot API with an article URL from pocket
  def self.grabJSON( article_path, diffbot_token ) 
    base = 'http://www.diffbot.com/api/article?summary=true&token=' + diffbot_token + '&url='
    uri = URI(base + article_path)
    resp = Net::HTTP.get(uri)
    return resp
  end

  # parse the response of the diffbot API into our format
  def self.parseJSON( resp )

    begin
      x = JSON.parse(resp)
    rescue
      return nil
    end
    
    # grab out parameters
    title = x['title'] || ''
    date = x['date'] || ''
    author = x['author'] || ''
    icon = x['icon'] || ''
    summary = x['summary'] || ''
    url = x['url'] || ''
    img = x['media'][0]['link'] rescue '' 
  
    # handle 'bad articles'
    if x['error']  
      # if its just a PDF we can continue, otherwise return fail
      return nil if !x['error'].include?('application/pdf')
      url = x['error'].split('pdf):')[1]
      title = url.split('/').last.split('.').first + '.pdf' rescue ''
    end
  
    # calculate source attribute from the url
    source = url.split('//').last || ''
    source = source.split(/[:\/]/)[0]
  
    return {
      'title' => title,
      'source' => source,
      'author' => author,
      'date' => date,
      'icon' => icon,
      'summary' => summary,
      'url' => url,
      'img' => img,
      'ts' => Time.now.strftime('%b %e')
    }
  
  end  

end

