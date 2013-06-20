require 'open-uri'
require 'net/http'

module SyncAPI
  DIFFBOT_TOKEN = 'd023c6283d89d44ab9e1f2c192811d9d'
  POCKET_USER = 'baygross'
  
  # main endpoint
  def self.pull()
    articles = []
    
    # get article links from Pocket RSS
    links = SyncAPI.grabRSS()
    
    # parse each link with DiffBot
    links.each(2) do |url, ts|
      
      content = SyncAPI.grabJSON( url ) 
      content = SyncAPI.parseJSON( content )
      next if !content
      content['timestamp'] = ts
      articles << content
       
    end
    
    return articles
  end


  :private
  
  # grabs RSS feed from pocket and strips to list of links
  def self.grabRSS()
    url = 'http://getpocket.com/users/' + POCKET_USER + '/feed/all'
    uri = URI(url)
    resp = Net::HTTP.get(uri)
    return resp.scan( /<guid>([^<]*)<\/guid>|<pubDate>([^<]*)<\/pubDate>/ )
  end


  # hit the diffbot API with an article URL from pocket
  def self.grabJSON( article_path ) 
    base = 'http://www.diffbot.com/api/article?summary=true&token=' + TOKEN + '&url='
    uri = URI(base + article_path)
    resp = Net::HTTP.get(uri)
    return resp
  end

  # parse the response of the diffbot API into our format
  def self.parseJSON( resp )

    x = JSON.parse(resp)
  
    # grab out parameters
    title = x['title'] || ''
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
      'icon' => icon,
      'summary' => summary,
      'url' => url,
      'img' => img
    }
  
  end  
  
end
